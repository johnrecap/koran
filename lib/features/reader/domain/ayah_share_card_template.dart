import 'package:flutter/widgets.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';

@immutable
class AyahShareTextSlot {
  const AyahShareTextSlot({
    required this.alignment,
    required this.padding,
    required this.maxLines,
    this.textAlign = TextAlign.center,
    this.fontSize = 24,
    this.textColor = const Color(0xFF1F1A17),
  });

  final Alignment alignment;
  final EdgeInsets padding;
  final int maxLines;
  final TextAlign textAlign;
  final double fontSize;
  final Color textColor;
}

@immutable
class AyahShareCardTemplate {
  const AyahShareCardTemplate({
    required this.id,
    required this.assetPath,
    required this.aspectRatio,
    required this.requiredAccessKey,
    required this.ayahSlot,
    required this.referenceSlot,
    required this.translationSlot,
  });

  final String id;
  final String assetPath;
  final double aspectRatio;
  final PremiumAccessKey? requiredAccessKey;
  final AyahShareTextSlot ayahSlot;
  final AyahShareTextSlot referenceSlot;
  final AyahShareTextSlot translationSlot;

  bool get isPremium => requiredAccessKey != null;
}

abstract final class AyahShareCardTemplateCatalog {
  static const defaults = <AyahShareCardTemplate>[
    AyahShareCardTemplate(
      id: 'photo-1',
      assetPath: 'assets/images/photo 1.png',
      aspectRatio: 1,
      requiredAccessKey: null,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-2',
      assetPath: 'assets/images/photo 2.png',
      aspectRatio: 1,
      requiredAccessKey: null,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-3',
      assetPath: 'assets/images/photo 3.png',
      aspectRatio: 1,
      requiredAccessKey: null,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-4',
      assetPath: 'assets/images/photo 4.png',
      aspectRatio: 1,
      requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-5',
      assetPath: 'assets/images/photo 5.png',
      aspectRatio: 1,
      requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-6',
      assetPath: 'assets/images/photo 6.png',
      aspectRatio: 1,
      requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-7',
      assetPath: 'assets/images/photo 7.png',
      aspectRatio: 1,
      requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-8',
      assetPath: 'assets/images/photo 8.png',
      aspectRatio: 1,
      requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-9',
      assetPath: 'assets/images/photo 9.png',
      aspectRatio: 1,
      requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
    AyahShareCardTemplate(
      id: 'photo-10',
      assetPath: 'assets/images/photo 10.png',
      aspectRatio: 1,
      requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
      ayahSlot: _defaultAyahSlot,
      referenceSlot: _defaultReferenceSlot,
      translationSlot: _defaultTranslationSlot,
    ),
  ];
}

const _defaultAyahSlot = AyahShareTextSlot(
  alignment: Alignment.center,
  padding: EdgeInsets.fromLTRB(28, 34, 28, 96),
  maxLines: 6,
  fontSize: 26,
);

const _defaultReferenceSlot = AyahShareTextSlot(
  alignment: Alignment.bottomCenter,
  padding: EdgeInsets.fromLTRB(28, 28, 28, 28),
  maxLines: 1,
  fontSize: 14,
);

const _defaultTranslationSlot = AyahShareTextSlot(
  alignment: Alignment.bottomCenter,
  padding: EdgeInsets.fromLTRB(28, 28, 28, 54),
  maxLines: 3,
  fontSize: 13,
  textColor: Color(0xFF54463C),
);
