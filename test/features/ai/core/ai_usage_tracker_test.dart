import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';
import 'package:quran_kareem/features/ai/core/ai_usage_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AiUsageTracker', () {
    test('fresh state starts with full default quota', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      );

      expect(tracker.remainingToday, 20);
      expect(tracker.isQuotaExhausted, isFalse);
    });

    test('increment reduces remaining quota', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      );

      for (var index = 0; index < 5; index += 1) {
        await tracker.increment();
      }

      expect(tracker.remainingToday, 15);
    });

    test('isQuotaExhausted becomes true after reaching quota', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      );

      for (var index = 0; index < 20; index += 1) {
        await tracker.increment();
      }

      expect(tracker.isQuotaExhausted, isTrue);
      expect(tracker.remainingToday, 0);
    });

    test('date change resets usage automatically', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AiUsageTracker.storageKey: jsonEncode(<String, Object>{
          'date': '2026-04-10',
          'count': 8,
        }),
      });
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      );

      expect(tracker.remainingToday, 20);
      expect(
        jsonDecode(prefs.getString(AiUsageTracker.storageKey)!)['count'],
        0,
      );
    });

    test('corrupted json resets gracefully', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AiUsageTracker.storageKey: 'not-json',
      });
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      );

      expect(tracker.remainingToday, 20);
      expect(tracker.isQuotaExhausted, isFalse);
    });

    test('premium users bypass the daily quota', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
        isPremium: true,
      )..setQuota(0);

      expect(tracker.isQuotaExhausted, isFalse);
      await tracker.increment();
      expect(tracker.isQuotaExhausted, isFalse);
    });

    test('logUsage persists request counters and averages', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      );

      await tracker.logUsage(AiFeatureType.simplifyTafsir, 100, true);
      await tracker.logUsage(AiFeatureType.simplifyTafsir, 300, false);

      final raw = prefs.getString(AiUsageTracker.analyticsStorageKey)!;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final stats =
          (decoded['stats'] as Map<String, dynamic>)['simplifyTafsir']
              as Map<String, dynamic>;

      expect(stats['requests'], 2);
      expect(stats['errors'], 1);
      expect(stats['avgLatencyMs'], 200);
    });
  });
}
