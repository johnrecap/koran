import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';

class ReaderTranslationRemoteException implements Exception {
  const ReaderTranslationRemoteException(this.message);

  final String message;

  @override
  String toString() => 'ReaderTranslationRemoteException: $message';
}

class ReaderTranslationPage {
  const ReaderTranslationPage({
    required this.translations,
    required this.nextPage,
  });

  final List<AyahTranslation> translations;
  final int? nextPage;
}

class ReaderTranslationRemoteDataSource {
  ReaderTranslationRemoteDataSource({
    required http.Client client,
    this.baseUrl = AppConstants.quranApiBaseUrl,
  }) : _client = client;

  final http.Client _client;
  final String baseUrl;

  Future<ReaderTranslationPage> fetchTranslationsPage({
    required int surahNumber,
    required int resourceId,
    int page = 1,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/verses/by_chapter/$surahNumber').replace(
        queryParameters: <String, String>{
          'translations': '$resourceId',
          'words': 'false',
          'per_page': '${AppConstants.translationApiPageSize}',
          'page': '$page',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw ReaderTranslationRemoteException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const ReaderTranslationRemoteException('Invalid response payload.');
    }

    final translations = <AyahTranslation>[];
    final verses = payload['verses'];
    if (verses is List) {
      for (final verse in verses) {
        if (verse is! Map<String, dynamic>) {
          continue;
        }

        final translation = _mapVerseTranslation(
          verse: verse,
          fallbackResourceId: resourceId,
        );
        if (translation != null) {
          translations.add(translation);
        }
      }
    }

    return ReaderTranslationPage(
      translations: translations,
      nextPage: _parseNextPage(payload['pagination']),
    );
  }

  AyahTranslation? _mapVerseTranslation({
    required Map<String, dynamic> verse,
    required int fallbackResourceId,
  }) {
    final ayahNumber = _parseAyahNumber(verse);
    final verseKey = verse['verse_key'] as String?;
    final translationRows = verse['translations'];

    if (ayahNumber == null ||
        verseKey == null ||
        translationRows is! List ||
        translationRows.isEmpty) {
      return null;
    }

    Map<String, dynamic>? matchedRow;
    for (final row in translationRows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }

      if (row['resource_id'] == fallbackResourceId) {
        matchedRow = row;
        break;
      }

      matchedRow ??= row;
    }

    if (matchedRow == null) {
      return null;
    }

    final rawText = matchedRow['text'] as String? ?? '';
    final normalizedText = _normalizeTranslationText(rawText);
    if (normalizedText.isEmpty) {
      return null;
    }

    return AyahTranslation(
      ayahNumber: ayahNumber,
      verseKey: verseKey,
      text: normalizedText,
      resourceId: matchedRow['resource_id'] as int? ?? fallbackResourceId,
    );
  }

  int? _parseAyahNumber(Map<String, dynamic> verse) {
    final verseNumber = verse['verse_number'];
    if (verseNumber is int) {
      return verseNumber;
    }

    final verseKey = verse['verse_key'] as String?;
    if (verseKey == null) {
      return null;
    }

    final segments = verseKey.split(':');
    if (segments.length != 2) {
      return null;
    }

    return int.tryParse(segments[1]);
  }

  int? _parseNextPage(Object? pagination) {
    if (pagination is! Map<String, dynamic>) {
      return null;
    }

    final nextPage = pagination['next_page'];
    if (nextPage is int) {
      return nextPage;
    }

    if (nextPage is String) {
      return int.tryParse(nextPage);
    }

    return null;
  }

  static String _normalizeTranslationText(String rawText) {
    return rawText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
