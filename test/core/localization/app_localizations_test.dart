import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations reader wave 1 strings', () {
    test('provides English reader chrome strings', () {
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.readerToggleToScroll, 'Switch to scroll mode');
      expect(l10n.readerToggleToPage, 'Switch to page mode');
      expect(l10n.readerQuickJump, 'Quick jump');
      expect(l10n.mushafFontsTitle, 'Mushaf fonts');
      expect(
        l10n.mushafFontsNotes,
        'Download the mushaf fonts to match the Madinah Mushaf appearance.',
      );
      expect(l10n.mushafFontsDownloading, 'Downloading...');
      expect(l10n.surahPrefix, 'Surah');
    });

    test('provides Arabic reader chrome strings', () {
      final l10n = AppLocalizations(const Locale('ar'));

      expect(l10n.readerToggleToScroll, 'تبديل إلى وضع التمرير');
      expect(l10n.readerToggleToPage, 'تبديل إلى وضع الصفحات');
      expect(l10n.mushafFontsTitle, 'خطوط المصحف');
      expect(
        l10n.mushafFontsNotes,
        'حمّل خطوط المصحف ليصبح مظهر القراءة أقرب إلى مصحف المدينة.',
      );
      expect(l10n.mushafFontsDownloading, 'جارٍ التحميل...');
      expect(l10n.surahPrefix, 'سورة');
    });
  });
  group('AppLocalizations interactive tafsir wave 8 strings', () {
    test('provides English insight-section strings', () {
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.insightSectionTafsir, 'Tafsir');
      expect(l10n.insightSectionWordMeaning, 'Word Meanings');
      expect(l10n.insightSectionAsbaab, 'Reasons for Revelation');
      expect(l10n.insightSectionRelated, 'Related Verses');
      expect(l10n.insightSectionUnavailable, 'Currently unavailable');
      expect(l10n.insightSectionCollapse, 'Collapse');
      expect(l10n.insightSectionExpand, 'Expand');
      expect(l10n.insightWordRoot, 'Root');
      expect(l10n.insightAsbaabSource, 'Source');
      expect(l10n.insightRelatedOpen, 'Open Verse');
      expect(l10n.insightRelatedTagThematic, 'Thematic');
      expect(l10n.insightRelatedTagLinguistic, 'Linguistic');
    });

    test('provides Arabic insight-section strings', () {
      final l10n = AppLocalizations(const Locale('ar'));

      expect(l10n.insightSectionTafsir, 'التفسير');
      expect(l10n.insightSectionWordMeaning, 'معاني الكلمات');
      expect(l10n.insightSectionAsbaab, 'أسباب النزول');
      expect(l10n.insightSectionRelated, 'آيات ذات صلة');
      expect(l10n.insightSectionUnavailable, 'غير متاح حاليًا');
      expect(l10n.insightSectionCollapse, 'طي');
      expect(l10n.insightSectionExpand, 'توسيع');
      expect(l10n.insightWordRoot, 'الجذر');
      expect(l10n.insightAsbaabSource, 'المصدر');
      expect(l10n.insightRelatedOpen, 'فتح الآية');
      expect(l10n.insightRelatedTagThematic, 'موضوعي');
      expect(l10n.insightRelatedTagLinguistic, 'لغوي');
    });
  });
}
