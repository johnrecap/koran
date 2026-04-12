import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_kareem/features/reader/data/reader_translation_remote_data_source.dart';

void main() {
  group('ReaderTranslationRemoteDataSource', () {
    test('maps Quran.com verses payload into translation entries', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.quran.com/api/v4/verses/by_chapter/1?translations=20&words=false&per_page=50&page=1',
        );

        return http.Response(
          jsonEncode({
            'verses': [
              {
                'verse_number': 1,
                'verse_key': '1:1',
                'translations': [
                  {
                    'id': 96343,
                    'resource_id': 20,
                    'text':
                        'In the name of Allah<sup foot_note=1>1</sup> the Merciful.',
                  },
                ],
              },
            ],
            'pagination': {
              'next_page': 2,
            },
          }),
          200,
        );
      });

      final dataSource = ReaderTranslationRemoteDataSource(client: client);

      final page = await dataSource.fetchTranslationsPage(
        surahNumber: 1,
        resourceId: 20,
      );

      expect(page.nextPage, 2);
      expect(page.translations, hasLength(1));
      expect(page.translations.first.ayahNumber, 1);
      expect(page.translations.first.verseKey, '1:1');
      expect(
        page.translations.first.text,
        'In the name of Allah 1 the Merciful.',
      );
    });

    test('skips verses that do not include translation rows', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'verses': [
              {
                'verse_number': 1,
                'verse_key': '1:1',
                'translations': [],
              },
              {
                'verse_number': 2,
                'verse_key': '1:2',
              },
              {
                'verse_number': 3,
                'verse_key': '1:3',
                'translations': [
                  {
                    'id': 96344,
                    'resource_id': 20,
                    'text': 'All praise is for Allah.',
                  },
                ],
              },
            ],
            'pagination': {
              'next_page': null,
            },
          }),
          200,
        );
      });

      final dataSource = ReaderTranslationRemoteDataSource(client: client);

      final page = await dataSource.fetchTranslationsPage(
        surahNumber: 1,
        resourceId: 20,
      );

      expect(page.nextPage, isNull);
      expect(page.translations, hasLength(1));
      expect(page.translations.single.ayahNumber, 3);
      expect(page.translations.single.verseKey, '1:3');
    });

    test('decodes common HTML entities in translation text', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'verses': [
              {
                'verse_number': 1,
                'verse_key': '1:1',
                'translations': [
                  {
                    'id': 96343,
                    'resource_id': 20,
                    'text':
                        'Mercy &lt;peace&gt; &quot;quotes&quot; &#39;single&#39; &amp; more',
                  },
                ],
              },
            ],
            'pagination': {
              'next_page': null,
            },
          }),
          200,
        );
      });

      final dataSource = ReaderTranslationRemoteDataSource(client: client);

      final page = await dataSource.fetchTranslationsPage(
        surahNumber: 1,
        resourceId: 20,
      );

      expect(
        page.translations.single.text,
        'Mercy <peace> "quotes" \'single\' & more',
      );
    });
  });
}
