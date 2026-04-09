import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/premium/data/premium_purchases_service.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/domain/premium_product_descriptor.dart';
import 'package:quran_kareem/features/premium/providers/premium_providers.dart';
import 'package:quran_kareem/features/reader/data/ayah_share_card_export_service.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_template.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_share_card_sheet.dart';
import 'package:quran_kareem/features/reader/providers/ayah_share_card_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  testWidgets('switches templates while keeping the same verse content visible',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          ayahShareCardTemplatesProvider.overrideWith((ref) {
            return [_templateA, _templateB];
          }),
          premiumPurchasesServiceProvider
              .overrideWithValue(_UnlockedPremiumPurchasesService()),
        ],
        child: const ReaderAyahShareCardSheet(payload: _payload),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('ayah-share-template-template-a')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('ayah-share-preview-template-a')),
      findsOneWidget,
    );
    expect(find.text(_payload.ayahText), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('ayah-share-template-template-b')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('ayah-share-preview-template-b')),
      findsOneWidget,
    );
    expect(find.text(_payload.ayahText), findsOneWidget);
  });

  testWidgets(
      'tapping a locked premium template opens the premium paywall and keeps the current selection',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          ayahShareCardTemplatesProvider.overrideWith((ref) {
            return [_templateA, _templateB];
          }),
          premiumPurchasesServiceProvider
              .overrideWithValue(_LockedPremiumPurchasesService()),
        ],
        child: const ReaderAyahShareCardSheet(payload: _payload),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('ayah-share-preview-template-a')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('ayah-share-template-template-b')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlock premium templates'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('ayah-share-preview-template-a')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('ayah-share-preview-template-b')),
      findsNothing,
    );
  });

  testWidgets('exports the selected card and forwards it to the share service',
      (
    tester,
  ) async {
    final exportService = _RecordingExportService();
    final shareService = _RecordingShareService();

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          ayahShareCardTemplatesProvider.overrideWith((ref) {
            return [_templateA, _templateB];
          }),
          ayahShareCardExportServiceProvider.overrideWithValue(exportService),
          ayahShareCardShareServiceProvider.overrideWithValue(shareService),
        ],
        child: const ReaderAyahShareCardSheet(payload: _payload),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Share image'));
    await tester.pumpAndSettle();

    expect(exportService.callCount, 1);
    expect(shareService.callCount, 1);
    expect(shareService.lastResult?.fileName, 'ayah-share-card.png');
  });

  testWidgets(
      'shows localized feedback and keeps the composer open on share errors', (
    tester,
  ) async {
    final exportService = _RecordingExportService();
    final shareService = _ThrowingShareService();

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          ayahShareCardTemplatesProvider.overrideWith((ref) {
            return [_templateA, _templateB];
          }),
          ayahShareCardExportServiceProvider.overrideWithValue(exportService),
          ayahShareCardShareServiceProvider.overrideWithValue(shareService),
        ],
        child: const ReaderAyahShareCardSheet(payload: _payload),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Share image'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to share this card right now.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('ayah-share-preview-template-a')),
      findsOneWidget,
    );
  });

  testWidgets(
      'shows the verse translation on the preview when enabled and available', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          ayahShareCardTemplatesProvider.overrideWith((ref) {
            return [_templateA, _templateB];
          }),
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            return <int, AyahTranslation>{
              1: const AyahTranslation(
                ayahNumber: 1,
                verseKey: '112:1',
                text: 'Say, He is Allah, the One.',
                resourceId: 85,
              ),
            };
          }),
        ],
        child: const ReaderAyahShareCardSheet(
          ayah: _ayah,
          payload: _arabicPayload,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('ayah-share-translation-toggle')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('ayah-share-translation-toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Say, He is Allah, the One.'), findsOneWidget);
  });

  testWidgets('keeps the card usable when translation is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          ayahShareCardTemplatesProvider.overrideWith((ref) {
            return [_templateA, _templateB];
          }),
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            return const <int, AyahTranslation>{};
          }),
        ],
        child: const ReaderAyahShareCardSheet(
          ayah: _ayah,
          payload: _arabicPayload,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Translation is unavailable for this verse.'),
        findsOneWidget);
    expect(find.text(_arabicPayload.ayahText), findsOneWidget);
    expect(find.text(_arabicPayload.referenceText), findsOneWidget);
  });

  testWidgets(
      'shows tadabbur reflection content without exposing translation controls',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          ayahShareCardTemplatesProvider.overrideWith((ref) {
            return [_templateA, _templateB];
          }),
        ],
        child: const ReaderAyahShareCardSheet(
          ayah: _ayah,
          allowTranslationToggle: false,
          payload: _reflectionPayload,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('ayah-share-translation-toggle')),
      findsNothing,
    );
    expect(find.text(_reflectionPayload.supportingText!), findsOneWidget);
    expect(find.text(_reflectionPayload.referenceText), findsOneWidget);
  });
}

Widget _buildHarness({
  required Widget child,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}

const _templateA = AyahShareCardTemplate(
  id: 'template-a',
  assetPath: 'assets/images/White stop.png',
  aspectRatio: 1,
  requiredAccessKey: null,
  ayahSlot: AyahShareTextSlot(
    alignment: Alignment.center,
    padding: EdgeInsets.all(24),
    maxLines: 4,
  ),
  referenceSlot: AyahShareTextSlot(
    alignment: Alignment.bottomCenter,
    padding: EdgeInsets.all(20),
    maxLines: 1,
  ),
  translationSlot: AyahShareTextSlot(
    alignment: Alignment.bottomCenter,
    padding: EdgeInsets.fromLTRB(20, 20, 20, 44),
    maxLines: 2,
  ),
);

const _templateB = AyahShareCardTemplate(
  id: 'template-b',
  assetPath: 'assets/images/Brown stop.png',
  aspectRatio: 1,
  requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
  ayahSlot: AyahShareTextSlot(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.all(16),
    maxLines: 5,
  ),
  referenceSlot: AyahShareTextSlot(
    alignment: Alignment.bottomCenter,
    padding: EdgeInsets.all(18),
    maxLines: 1,
  ),
  translationSlot: AyahShareTextSlot(
    alignment: Alignment.bottomCenter,
    padding: EdgeInsets.fromLTRB(18, 18, 18, 40),
    maxLines: 2,
  ),
);

const _payload = AyahShareCardPayload(
  ayahText: 'Say, He is Allah, the One.',
  referenceText: '[Surah Al-Ikhlas]',
  supportingText: null,
);

const _arabicPayload = AyahShareCardPayload(
  ayahText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
  referenceText: '[سورة الإخلاص]',
  supportingText: null,
);

const _reflectionPayload = AyahShareCardPayload(
  ayahText: 'Say, He is Allah, the One.',
  referenceText: '[Surah Al-Ikhlas]',
  supportingText: 'A reminder that divine oneness simplifies every fear.',
);

const _ayah = Ayah(
  id: 6237,
  surahNumber: 112,
  ayahNumber: 1,
  text: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
  page: 604,
  juz: 30,
  hizb: 4,
);

class _RecordingExportService implements AyahShareCardExportService {
  int callCount = 0;

  @override
  Future<AyahShareCardExportResult> export({
    required GlobalKey repaintBoundaryKey,
    required AyahShareCardTemplate template,
    required AyahShareCardPayload payload,
  }) async {
    callCount += 1;
    return const AyahShareCardExportResult(
      filePath: '/tmp/ayah-share-card.png',
      fileName: 'ayah-share-card.png',
    );
  }
}

class _RecordingShareService implements AyahShareCardShareService {
  int callCount = 0;
  AyahShareCardExportResult? lastResult;

  @override
  Future<void> share(AyahShareCardExportResult result) async {
    callCount += 1;
    lastResult = result;
  }
}

class _ThrowingShareService implements AyahShareCardShareService {
  @override
  Future<void> share(AyahShareCardExportResult result) {
    throw Exception('share failed');
  }
}

class _UnlockedPremiumPurchasesService implements PremiumPurchasesService {
  @override
  Future<void> initialize() async {}

  @override
  Future<PremiumProductDescriptor?> loadProductDescriptor() async => null;

  @override
  Future<PremiumEntitlementSnapshot> loadSnapshot() async {
    return const PremiumEntitlementSnapshot.premium();
  }

  @override
  Future<PremiumEntitlementSnapshot> purchasePremium() async {
    return const PremiumEntitlementSnapshot.premium();
  }

  @override
  Future<PremiumEntitlementSnapshot> restorePurchases() async {
    return const PremiumEntitlementSnapshot.premium();
  }
}

class _LockedPremiumPurchasesService implements PremiumPurchasesService {
  @override
  Future<void> initialize() async {}

  @override
  Future<PremiumProductDescriptor?> loadProductDescriptor() async {
    return const PremiumProductDescriptor(
      title: 'Ayah Share Cards Pro',
      subtitle: 'Unlock premium templates',
      packageId: 'ayah_cards_pro_monthly',
    );
  }

  @override
  Future<PremiumEntitlementSnapshot> loadSnapshot() async {
    return const PremiumEntitlementSnapshot.free();
  }

  @override
  Future<PremiumEntitlementSnapshot> purchasePremium() async {
    return const PremiumEntitlementSnapshot.premium();
  }

  @override
  Future<PremiumEntitlementSnapshot> restorePurchases() async {
    return const PremiumEntitlementSnapshot.premium();
  }
}
