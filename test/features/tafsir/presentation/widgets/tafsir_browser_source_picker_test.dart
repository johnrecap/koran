import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_source_option.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/tafsir_browser_source_picker.dart';

void main() {
  test('buildTafsirBrowserSourceItems disables undownloaded sources', () {
    final items = buildTafsirBrowserSourceItems(
      const [
        TafsirBrowserSourceOption(
          id: 'saadi',
          title: 'Tafsir Al-Saadi',
          bookName: 'Saadi',
          isTranslation: false,
          isSelected: true,
          isDownloaded: true,
        ),
        TafsirBrowserSourceOption(
          id: 'ibn-kathir',
          title: 'Tafsir Ibn Kathir',
          bookName: 'Ibn Kathir',
          isTranslation: false,
          isSelected: false,
          isDownloaded: false,
        ),
      ],
    );

    final unavailableItem =
        items.singleWhere((item) => item.value == 'ibn-kathir');
    expect(unavailableItem.enabled, isFalse);
  });
}
