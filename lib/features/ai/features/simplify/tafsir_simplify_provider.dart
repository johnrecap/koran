import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

class TafsirSimplifyRequest {
  const TafsirSimplifyRequest({
    required this.surah,
    required this.ayah,
    required this.tafsirText,
  });

  final int surah;
  final int ayah;
  final String tafsirText;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TafsirSimplifyRequest &&
            other.surah == surah &&
            other.ayah == ayah &&
            other.tafsirText == tafsirText);
  }

  @override
  int get hashCode => Object.hash(surah, ayah, tafsirText);
}

final tafsirSimplifyProvider =
    FutureProvider.family<AiResponse, TafsirSimplifyRequest>((
  ref,
  request,
) async {
  final aiService = await ref.watch(aiServiceProvider.future);
  return aiService.simplifyTafsir(
    request.surah,
    request.ayah,
    request.tafsirText,
  );
});
