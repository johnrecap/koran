import 'dart:convert';

class AiSearchResult {
  const AiSearchResult({
    required this.surah,
    required this.ayah,
    required this.verseTextAr,
    required this.contextNote,
    this.relevanceScore,
  });

  factory AiSearchResult.fromJson(Map<String, dynamic> json) {
    return AiSearchResult(
      surah: _readInt(json['surah']),
      ayah: _readInt(json['ayah']),
      verseTextAr: _readString(
        json['verseTextAr'] ?? json['verse_text'] ?? json['verse'],
      ),
      contextNote: _readString(
        json['contextNote'] ?? json['context'] ?? json['note'],
      ),
      relevanceScore: _readDouble(
        json['relevanceScore'] ?? json['relevance_score'],
      ),
    );
  }

  static List<AiSearchResult> parseResults(String aiResponseText) {
    final trimmed = aiResponseText.trim();
    if (trimmed.isEmpty) {
      return const <AiSearchResult>[];
    }

    final jsonResults = _parseJsonResults(trimmed);
    if (jsonResults.isNotEmpty) {
      return jsonResults;
    }

    return _parseRegexResults(trimmed);
  }

  final int surah;
  final int ayah;
  final String verseTextAr;
  final String contextNote;
  final double? relevanceScore;

  static List<AiSearchResult> _parseJsonResults(String responseText) {
    final candidate = _extractJsonArray(responseText);
    if (candidate == null) {
      return const <AiSearchResult>[];
    }

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is! List) {
        return const <AiSearchResult>[];
      }

      return decoded
          .whereType<Map>()
          .map((item) =>
              AiSearchResult.fromJson(Map<String, dynamic>.from(item)))
          .where(_isValid)
          .toList(growable: false);
    } catch (_) {
      return const <AiSearchResult>[];
    }
  }

  static List<AiSearchResult> _parseRegexResults(String responseText) {
    final pattern = RegExp(
      r'surah\s*:\s*(\d+)\s*,?\s*ayah\s*:\s*(\d+)\s*,?\s*verse_text\s*:\s*"([^"]+)"\s*,?\s*context\s*:\s*"([^"]+)"',
      caseSensitive: false,
      dotAll: true,
    );

    return pattern
        .allMatches(responseText)
        .map(
          (match) => AiSearchResult(
            surah: int.parse(match.group(1)!),
            ayah: int.parse(match.group(2)!),
            verseTextAr: match.group(3)!.trim(),
            contextNote: match.group(4)!.trim(),
          ),
        )
        .where(_isValid)
        .toList(growable: false);
  }

  static String? _extractJsonArray(String responseText) {
    final fencePattern = RegExp(r'```(?:json)?\s*(\[.*\])\s*```', dotAll: true);
    final fenced = fencePattern.firstMatch(responseText);
    if (fenced != null) {
      return fenced.group(1);
    }

    final start = responseText.indexOf('[');
    final end = responseText.lastIndexOf(']');
    if (start == -1 || end == -1 || end <= start) {
      return null;
    }

    return responseText.substring(start, end + 1);
  }

  static bool _isValid(AiSearchResult result) {
    return result.surah >= 1 &&
        result.surah <= 114 &&
        result.ayah >= 1 &&
        result.verseTextAr.isNotEmpty &&
        result.contextNote.isNotEmpty;
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}
