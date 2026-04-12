import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/ai/core/ai_config.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';
import 'package:quran_kareem/features/ai/core/ai_service.dart';
import 'package:quran_kareem/features/ai/core/ai_usage_tracker.dart';
import 'package:quran_kareem/features/ai/providers/gemini_ai_provider.dart';
import 'package:quran_kareem/features/ai/providers/groq_ai_provider.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';
import 'package:quran_kareem/features/premium/providers/premium_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AiPreferencesLoader = Future<SharedPreferences> Function();
typedef AiVerseLoader = Future<Ayah?> Function(int surah, int ayah);
typedef AiSearchPageResolver = Future<int> Function(int surah, int ayah);

final geminiApiKeyProvider = Provider<String>(
  (ref) => AiProviderConfig.gemini().apiKey,
);

final groqApiKeyProvider = Provider<String>(
  (ref) => AiProviderConfig.groq().apiKey,
);

final aiAvailableProvider = Provider<bool>((ref) {
  final geminiKey = ref.watch(geminiApiKeyProvider).trim();
  final groqKey = ref.watch(groqApiKeyProvider).trim();
  return geminiKey.isNotEmpty || groqKey.isNotEmpty;
});

final aiSafetyPolicyProvider = Provider<AiSafetyPolicy>(
  (ref) => const AiSafetyPolicy(),
);

final aiPreferencesLoaderProvider = Provider<AiPreferencesLoader>(
  (ref) => () => UserPreferences.prefs,
);

final aiSharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return ref.watch(aiPreferencesLoaderProvider)();
});

final aiVerseLoaderProvider = Provider<AiVerseLoader>(
  (ref) => QuranDatabase.getAyah,
);

final aiSearchPageResolverProvider = Provider<AiSearchPageResolver>(
  (ref) => QuranDatabase.getPageForAyah,
);

final aiProviderProvider = Provider<AiProvider>((ref) {
  final gemini = GeminiAiProvider(
    AiProviderConfig.gemini(ref.watch(geminiApiKeyProvider)),
  );
  final groq = GroqAiProvider(
    AiProviderConfig.groq(ref.watch(groqApiKeyProvider)),
  );
  final hasGemini = ref.watch(geminiApiKeyProvider).trim().isNotEmpty;
  final hasGroq = ref.watch(groqApiKeyProvider).trim().isNotEmpty;

  if (hasGemini && hasGroq) {
    return AiFallbackProvider(primary: gemini, fallback: groq);
  }
  if (hasGroq) {
    return groq;
  }
  return gemini;
});

final aiUsageTrackerProvider = FutureProvider<AiUsageTracker>((ref) async {
  final prefs = await ref.watch(aiSharedPreferencesProvider.future);
  final isPremium = ref.watch(
    hasPremiumAccessProvider(PremiumAccessKey.aiFeatures),
  );
  return AiUsageTracker(
    prefs,
    isPremium: isPremium,
  );
});

final aiServiceProvider = FutureProvider<AiService>((ref) async {
  final usageTracker = await ref.watch(aiUsageTrackerProvider.future);
  return AiService(
    provider: ref.watch(aiProviderProvider),
    usageTracker: usageTracker,
    safetyPolicy: ref.watch(aiSafetyPolicyProvider),
  );
});

final aiQuotaRemainingProvider = FutureProvider<int>((ref) async {
  final tracker = await ref.watch(aiUsageTrackerProvider.future);
  return tracker.remainingToday;
});

final aiQuotaExhaustedProvider = FutureProvider<bool>((ref) async {
  final tracker = await ref.watch(aiUsageTrackerProvider.future);
  return tracker.isQuotaExhausted;
});
