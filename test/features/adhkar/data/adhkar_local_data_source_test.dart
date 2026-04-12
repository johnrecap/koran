import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/adhkar/data/adhkar_local_data_source.dart';

void main() {
  test('loads the bundled adhkar catalog and preserves trusted metadata',
      () async {
    final source = AssetAdhkarCatalogSource(
      bundle: _FakeAssetBundle(
        <String, String>{
          'assets/adhkar/adhkar_catalog.json': '''
{
  "categories": [
    {
      "id": "morning",
      "groupId": "dailyCore",
      "sourceLabel": "السنة الصحيحة",
      "sourceNote": "مختارات",
      "entries": [
        {
          "id": "entry-1",
          "arabicText": "رضيت بالله ربا",
          "repetitionCount": 3,
          "reference": "ذكر مأثور"
        }
      ]
    }
  ]
}
''',
        },
      ),
    );

    final catalog = await source.loadCatalog();

    expect(catalog.categories, hasLength(1));
    expect(catalog.categories.first.id, 'morning');
    expect(catalog.categories.first.groupId, 'dailyCore');
    expect(catalog.categories.first.sourceLabel, 'السنة الصحيحة');
    expect(catalog.categories.first.entries.first.repetitionCount, 3);
    expect(catalog.categories.first.entries.first.reference, 'ذكر مأثور');
  });

  test('throws a format exception when the adhkar asset is malformed',
      () async {
    final source = AssetAdhkarCatalogSource(
      bundle: _FakeAssetBundle(
        <String, String>{
          'assets/adhkar/adhkar_catalog.json': '{"categories":"bad"}',
        },
      ),
    );

    expect(source.loadCatalog, throwsFormatException);
  });

  test('preserves structured virtue, source detail, authenticity, and timing',
      () async {
    final source = AssetAdhkarCatalogSource(
      bundle: _FakeAssetBundle(
        <String, String>{
          'assets/adhkar/adhkar_catalog.json': '''
{
  "categories": [
    {
      "id": "sleep",
      "groupId": "dailyCore",
      "sourceLabel": "السنة الصحيحة",
      "entries": [
        {
          "id": "entry-virtue",
          "arabicText": "باسمك اللهم أموت وأحيا",
          "reference": "البخاري",
          "virtue": "يختم يومه بذكر الله قبل النوم.",
          "sourceDetail": "رواه البخاري في كتاب الدعوات.",
          "authenticityNote": "حديث صحيح.",
          "timingNote": "يقال عند وضع الجنب على الفراش."
        }
      ]
    }
  ]
}
''',
        },
      ),
    );

    final catalog = await source.loadCatalog();
    final entry = catalog.categories.first.entries.first as dynamic;

    expect(entry.virtue, 'يختم يومه بذكر الله قبل النوم.');
    expect(entry.sourceDetail, 'رواه البخاري في كتاب الدعوات.');
    expect(entry.authenticityNote, 'حديث صحيح.');
    expect(entry.timingNote, 'يقال عند وضع الجنب على الفراش.');
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this.values);

  final Map<String, String> values;

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = values[key];
    if (value == null) {
      throw StateError('Missing asset: $key');
    }
    return value;
  }
}
