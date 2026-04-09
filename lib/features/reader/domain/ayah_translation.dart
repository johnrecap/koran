import 'package:flutter/foundation.dart';

@immutable
class AyahTranslation {
  const AyahTranslation({
    required this.ayahNumber,
    required this.verseKey,
    required this.text,
    required this.resourceId,
  });

  final int ayahNumber;
  final String verseKey;
  final String text;
  final int resourceId;
}
