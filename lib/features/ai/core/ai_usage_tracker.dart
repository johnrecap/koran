import 'dart:async';
import 'dart:convert';

import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef CurrentDateProvider = DateTime Function();

class AiUsageTracker {
  AiUsageTracker(
    this._prefs, {
    this.currentDateProvider = _defaultNow,
    int quota = 20,
    this.isPremium = false,
  }) : _quota = quota;

  static const String storageKey = StorageKeys.aiDailyUsage;
  static const String analyticsStorageKey = StorageKeys.aiUsageLog;

  final SharedPreferences _prefs;
  final CurrentDateProvider currentDateProvider;
  final bool isPremium;
  int _quota;

  int get remainingToday {
    if (isPremium) {
      return _quota;
    }
    final state = _loadState();
    return _quota > state.count ? _quota - state.count : 0;
  }

  bool get isQuotaExhausted => !isPremium && remainingToday <= 0;

  Future<void> increment() async {
    if (isPremium) {
      return;
    }
    final state = _loadState();
    final nextState = _AiUsageState(
      date: state.date,
      count: state.count + 1,
    );
    await _persistState(nextState);
  }

  void setQuota(int max) {
    _quota = max < 0 ? 0 : max;
  }

  Future<void> logUsage(
    AiFeatureType feature,
    int latencyMs,
    bool success,
  ) async {
    final currentMonth = _monthKey(currentDateProvider());
    final raw = _prefs.getString(analyticsStorageKey);
    Map<String, dynamic> decoded = <String, dynamic>{};

    if (raw != null && raw.isNotEmpty) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map<String, dynamic>) {
          decoded = parsed;
        }
      } catch (error, stackTrace) {
        AppLogger.error('AiUsageTracker.logUsage', error, stackTrace);
      }
    }

    final storedMonth = decoded['month']?.toString();
    final stats = storedMonth == currentMonth
        ? Map<String, dynamic>.from(decoded['stats'] as Map? ?? const {})
        : <String, dynamic>{};

    final featureKey = feature.name;
    final current = Map<String, dynamic>.from(
      stats[featureKey] as Map? ??
          const {
            'requests': 0,
            'errors': 0,
            'avgLatencyMs': 0,
          },
    );

    final requests = ((current['requests'] as num?) ?? 0).toInt() + 1;
    final errors = ((current['errors'] as num?) ?? 0).toInt() + (success ? 0 : 1);
    final previousAvg = ((current['avgLatencyMs'] as num?) ?? 0).toDouble();
    final nextAvg = requests == 1
        ? latencyMs.toDouble()
        : ((previousAvg * (requests - 1)) + latencyMs) / requests;

    stats[featureKey] = <String, Object>{
      'requests': requests,
      'errors': errors,
      'avgLatencyMs': nextAvg.round(),
    };

    await _prefs.setString(
      analyticsStorageKey,
      jsonEncode(<String, Object>{
        'month': currentMonth,
        'stats': stats,
      }),
    );
  }

  _AiUsageState _loadState() {
    final today = _dateKey(currentDateProvider());
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return _resetState(today);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return _resetState(today);
      }

      final storedDate = decoded['date']?.toString() ?? today;
      final count = decoded['count'] is int
          ? decoded['count'] as int
          : int.tryParse(decoded['count']?.toString() ?? '') ?? 0;

      if (storedDate != today) {
        return _resetState(today);
      }

      return _AiUsageState(
        date: storedDate,
        count: count < 0 ? 0 : count,
      );
    } catch (error, stackTrace) {
      AppLogger.error('AiUsageTracker._loadState', error, stackTrace);
      return _resetState(today);
    }
  }

  _AiUsageState _resetState(String today) {
    final state = _AiUsageState(date: today, count: 0);
    unawaited(_persistState(state));
    return state;
  }

  Future<void> _persistState(_AiUsageState state) {
    return _prefs.setString(
      storageKey,
      jsonEncode(<String, Object>{
        'date': state.date,
        'count': state.count,
      }),
    );
  }

  static DateTime _defaultNow() => DateTime.now();

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _monthKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    return '${value.year}-$month';
  }
}

class _AiUsageState {
  const _AiUsageState({
    required this.date,
    required this.count,
  });

  final String date;
  final int count;
}
