import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/domain/verse_identifier.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

final tadabburQuestionsProvider =
    FutureProvider.family<List<String>, VerseIdentifier>((ref, verse) async {
  final loadVerse = ref.watch(aiVerseLoaderProvider);
  final verseText = (await loadVerse(verse.surah, verse.ayah))?.text;
  if (verseText == null || verseText.trim().isEmpty) {
    throw AiProviderException(
      message: 'Verse text is unavailable for tadabbur generation.',
      provider: 'local-quran',
    );
  }

  final aiService = await ref.watch(aiServiceProvider.future);
  return aiService.generateTadabburQuestions(
    verse.surah,
    verse.ayah,
    verseText,
  );
});
