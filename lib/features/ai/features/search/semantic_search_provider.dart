import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/ai/domain/ai_search_result.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

final semanticSearchProvider =
    FutureProvider.family<List<AiSearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return const <AiSearchResult>[];
  }

  final aiService = await ref.watch(aiServiceProvider.future);
  return aiService.searchByTopic(query);
});
