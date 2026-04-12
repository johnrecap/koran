import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/constants/app_constants.dart';

class LibraryTranslationSearchRemoteException implements Exception {
  const LibraryTranslationSearchRemoteException(this.message);

  final String message;

  @override
  String toString() => 'LibraryTranslationSearchRemoteException: $message';
}

class LibraryTranslationSearchMatch {
  const LibraryTranslationSearchMatch({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.translationText,
  });

  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String translationText;
}

abstract class LibraryTranslationSearchSource {
  Future<List<LibraryTranslationSearchMatch>> searchTranslations({
    required String query,
    required int resourceId,
  });
}

class LibraryTranslationSearchRemoteDataSource
    implements LibraryTranslationSearchSource {
  LibraryTranslationSearchRemoteDataSource({
    required http.Client client,
    this.baseUrl = AppConstants.quranApiBaseUrl,
  }) : _client = client;

  static const int _defaultSearchSize = 20;

  final http.Client _client;
  final String baseUrl;

  @override
  Future<List<LibraryTranslationSearchMatch>> searchTranslations({
    required String query,
    required int resourceId,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return const <LibraryTranslationSearchMatch>[];
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/search').replace(
        queryParameters: <String, String>{
          'q': normalizedQuery,
          'size': '$_defaultSearchSize',
          'language': 'en',
          'translations': '$resourceId',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw LibraryTranslationSearchRemoteException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const LibraryTranslationSearchRemoteException(
        'Invalid response payload.',
      );
    }

    final search = payload['search'];
    if (search is! Map<String, dynamic>) {
      return const <LibraryTranslationSearchMatch>[];
    }

    final rawResults = search['results'];
    if (rawResults is! List) {
      return const <LibraryTranslationSearchMatch>[];
    }

    final matches = <LibraryTranslationSearchMatch>[];
    for (final rawResult in rawResults) {
      if (rawResult is! Map<String, dynamic>) {
        continue;
      }

      final match = _mapResult(
        rawResult,
        fallbackResourceId: resourceId,
      );
      if (match != null) {
        matches.add(match);
      }
    }

    return matches;
  }

  LibraryTranslationSearchMatch? _mapResult(
    Map<String, dynamic> rawResult, {
    required int fallbackResourceId,
  }) {
    final verseKey = rawResult['verse_key'] as String?;
    final arabicText = (rawResult['text'] as String? ?? '').trim();
    final translations = rawResult['translations'];
    final verseAddress = _parseVerseKey(verseKey);

    if (verseAddress == null ||
        arabicText.isEmpty ||
        translations is! List ||
        translations.isEmpty) {
      return null;
    }

    Map<String, dynamic>? matchedTranslation;
    for (final item in translations) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      if (item['resource_id'] == fallbackResourceId) {
        matchedTranslation = item;
        break;
      }

      matchedTranslation ??= item;
    }

    if (matchedTranslation == null) {
      return null;
    }

    final translationText = _normalizeTranslationText(
      matchedTranslation['text'] as String? ?? '',
    );
    if (translationText.isEmpty) {
      return null;
    }

    return LibraryTranslationSearchMatch(
      surahNumber: verseAddress.surahNumber,
      ayahNumber: verseAddress.ayahNumber,
      arabicText: arabicText,
      translationText: translationText,
    );
  }

  _VerseAddress? _parseVerseKey(String? verseKey) {
    if (verseKey == null) {
      return null;
    }

    final segments = verseKey.split(':');
    if (segments.length != 2) {
      return null;
    }

    final surahNumber = int.tryParse(segments[0]);
    final ayahNumber = int.tryParse(segments[1]);
    if (surahNumber == null || ayahNumber == null) {
      return null;
    }

    return _VerseAddress(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
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

class _VerseAddress {
  const _VerseAddress({
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;
}
