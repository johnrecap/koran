import 'dart:convert';

import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';

abstract interface class MuallimSessionStore {
  Future<MuallimResumeSession?> load();
  Future<void> save(MuallimResumeSession session);
  Future<void> clear();
}

class SharedPreferencesMuallimSessionStore implements MuallimSessionStore {
  const SharedPreferencesMuallimSessionStore();

  @override
  Future<void> clear() async {
    final prefs = await UserPreferences.prefs;
    await prefs.remove(StorageKeys.muallimResumeSession);
  }

  @override
  Future<MuallimResumeSession?> load() async {
    final prefs = await UserPreferences.prefs;
    final raw = prefs.getString(StorageKeys.muallimResumeSession);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await clear();
        return null;
      }
      return MuallimResumeSession.fromMap(decoded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesMuallimSessionStore.load',
        error,
        stackTrace,
      );
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(MuallimResumeSession session) async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(
      StorageKeys.muallimResumeSession,
      jsonEncode(session.toMap()),
    );
  }
}
