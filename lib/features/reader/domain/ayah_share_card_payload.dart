import 'package:flutter/foundation.dart';

@immutable
class AyahShareCardPayload {
  const AyahShareCardPayload({
    required this.ayahText,
    required this.referenceText,
    required this.supportingText,
  });

  final String ayahText;
  final String referenceText;
  final String? supportingText;

  bool get hasSupportingText =>
      supportingText != null && supportingText!.trim().isNotEmpty;

  AyahShareCardPayload copyWith({
    String? ayahText,
    String? referenceText,
    String? supportingText,
  }) {
    return AyahShareCardPayload(
      ayahText: ayahText ?? this.ayahText,
      referenceText: referenceText ?? this.referenceText,
      supportingText: supportingText ?? this.supportingText,
    );
  }
}
