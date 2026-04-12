import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/domain/verse_identifier.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

final verseContextProvider =
    FutureProvider.family<AiResponse, VerseIdentifier>((ref, verse) async {
  final loadVerse = ref.watch(aiVerseLoaderProvider);
  final beforeVerse = verse.ayah > 1
      ? (await loadVerse(verse.surah, verse.ayah - 1))?.text
      : null;
  final afterVerse = (await loadVerse(verse.surah, verse.ayah + 1))?.text;
  final aiService = await ref.watch(aiServiceProvider.future);

  return aiService.getVerseContext(
    verse.surah,
    verse.ayah,
    beforeVerse: beforeVerse,
    afterVerse: afterVerse,
  );
});
