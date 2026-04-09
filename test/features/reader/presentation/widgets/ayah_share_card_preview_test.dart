import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_template.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/ayah_share_card_preview.dart';

void main() {
  testWidgets('renders ayah text and localized reference on the card preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AyahShareCardPreview(
            template: _template,
            payload: _payload,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_payload.ayahText), findsOneWidget);
    expect(find.text(_payload.referenceText), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('ayah-share-preview-test-template')),
      findsOneWidget,
    );
  });

  testWidgets('shows a fallback surface when the template asset is unavailable',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AyahShareCardPreview(
            template: _missingAssetTemplate,
            payload: _payload,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey<String>(
          'ayah-share-background-fallback-missing-template',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(_payload.ayahText), findsOneWidget);
  });
}

const _template = AyahShareCardTemplate(
  id: 'test-template',
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

const _payload = AyahShareCardPayload(
  ayahText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
  referenceText: '[سورة الإخلاص]',
  supportingText: null,
);

const _missingAssetTemplate = AyahShareCardTemplate(
  id: 'missing-template',
  assetPath: 'assets/images/not-found.png',
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
