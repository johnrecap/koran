import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';
import 'package:quran_kareem/features/ai/core/ai_usage_tracker.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/domain/ai_search_result.dart';

class AiService {
  AiService({
    required AiProvider provider,
    required AiUsageTracker usageTracker,
    required AiSafetyPolicy safetyPolicy,
  })  : _provider = provider,
        _usageTracker = usageTracker,
        _safetyPolicy = safetyPolicy;

  final AiProvider _provider;
  final AiUsageTracker _usageTracker;
  final AiSafetyPolicy _safetyPolicy;

  Future<AiResponse> simplifyTafsir(
    int surah,
    int ayah,
    String tafsirText,
  ) {
    return _generateResponse(
      feature: AiFeatureType.simplifyTafsir,
      prompt:
          'بسّط التفسير التالي للآية [$surah:$ayah]:\n\n$tafsirText\n\nالملخص:',
      maxTokens: 300,
      temperature: 0.3,
    );
  }

  Future<List<AiSearchResult>> searchByTopic(
    String query, {
    String language = 'ar',
  }) async {
    if (query.trim().isEmpty) {
      return const <AiSearchResult>[];
    }

    final response = await _generateResponse(
      feature: AiFeatureType.semanticSearch,
      prompt:
          'ابحث عن الآيات القرآنية المتعلقة بموضوع: $query\n\nلغة الشرح: $language\n\n'
          'لكل آية أعطني:\n- رقم السورة\n- رقم الآية\n- نص الآية\n- سبب الصلة بالموضوع\n\n'
          'أعد النتائج بتنسيق JSON.',
      maxTokens: 2000,
      temperature: 0.2,
    );

    return AiSearchResult.parseResults(response.text);
  }

  Future<AiResponse> getVerseContext(
    int surah,
    int ayah, {
    String? beforeVerse,
    String? afterVerse,
  }) {
    final contextBuffer = StringBuffer()
      ..writeln('الآية الحالية [$surah:$ayah].')
      ..writeln('الآية السابقة: ${beforeVerse ?? 'غير متوفرة'}.')
      ..writeln('الآية التالية: ${afterVerse ?? 'غير متوفرة'}.')
      ..writeln('اشرح الربط الموضوعي والبلاغي بإيجاز.');

    return _generateResponse(
      feature: AiFeatureType.verseContext,
      prompt: contextBuffer.toString(),
      maxTokens: 500,
      temperature: 0.3,
    );
  }

  Future<List<String>> generateTadabburQuestions(
    int surah,
    int ayah,
    String verseText,
  ) async {
    final response = await _generateResponse(
      feature: AiFeatureType.tadabburQuestions,
      prompt:
          'اكتب 3 أسئلة تدبرية عن الآية [$surah:$ayah]:\n\n$verseText\n\nالأسئلة:',
      maxTokens: 300,
      temperature: 0.5,
    );

    return response.text
        .split(RegExp(r'[\r\n]+'))
        .map(
            (line) => line.replaceFirst(RegExp(r'^\s*[-*\d.)]+\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(3)
        .toList(growable: false);
  }

  Future<AiResponse> summarizeJuz(int juzNumber) {
    return _generateResponse(
      feature: AiFeatureType.juzSummary,
      prompt:
          'لخّص الموضوعات الرئيسية في الجزء رقم $juzNumber من القرآن الكريم.',
      maxTokens: 500,
      temperature: 0.3,
    );
  }

  Future<AiResponse> _generateResponse({
    required AiFeatureType feature,
    required String prompt,
    required int maxTokens,
    required double temperature,
  }) async {
    if (_usageTracker.isQuotaExhausted) {
      await _usageTracker.logUsage(feature, 0, false);
      throw AiQuotaExceededException(
        message: 'Daily AI quota exhausted.',
        provider: _provider.providerName,
      );
    }

    if (!await _provider.isAvailable()) {
      await _usageTracker.logUsage(feature, 0, false);
      throw AiOfflineException(
        message: 'AI provider is unavailable.',
        provider: _provider.providerName,
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final rawResponse = await _provider.generate(
        prompt: prompt,
        systemPrompt: _safetyPolicy.buildSystemPrompt(feature),
        maxTokens: maxTokens,
        temperature: temperature,
      );
      stopwatch.stop();

      if (!_safetyPolicy.validateResponse(rawResponse)) {
        await _usageTracker.logUsage(
          feature,
          stopwatch.elapsedMilliseconds,
          false,
        );
        throw AiSafetyException(
          message: 'AI response failed safety validation.',
          provider: _provider.providerName,
        );
      }

      await _usageTracker.increment();
      await _usageTracker.logUsage(
        feature,
        stopwatch.elapsedMilliseconds,
        true,
      );
      return AiResponse.fromRaw(
        rawResponse,
        _provider.providerName,
        stopwatch.elapsedMilliseconds,
      );
    } catch (error) {
      if (stopwatch.isRunning) {
        stopwatch.stop();
      }
      if (error is! AiSafetyException) {
        await _usageTracker.logUsage(
          feature,
          stopwatch.elapsedMilliseconds,
          false,
        );
      }
      rethrow;
    }
  }
}
