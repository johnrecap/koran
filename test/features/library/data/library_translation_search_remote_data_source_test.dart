import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_kareem/features/library/data/library_translation_search_remote_data_source.dart';

void main() {
  test('maps Quran.com search payload into translation search matches',
      () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://api.quran.com/api/v4/search?q=mercy&size=20&language=en&translations=85',
      );

      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'search': {
              'results': [
                {
                  'verse_key': '2:255',
                  'text': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
                  'translations': [
                    {
                      'text':
                          'Allah! There is no deity except Him, the Ever-Living, the Sustainer.',
                      'resource_id': 85,
                    },
                  ],
                },
              ],
            },
          }),
        ),
        200,
        headers: const <String, String>{
          'content-type': 'application/json; charset=utf-8',
        },
      );
    });

    final dataSource = LibraryTranslationSearchRemoteDataSource(client: client);

    final results = await dataSource.searchTranslations(
      query: 'mercy',
      resourceId: 85,
    );

    expect(results, hasLength(1));
    expect(results.single.surahNumber, 2);
    expect(results.single.ayahNumber, 255);
    expect(results.single.arabicText, 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ');
    expect(results.single.translationText, contains('Ever-Living'));
  });
}
