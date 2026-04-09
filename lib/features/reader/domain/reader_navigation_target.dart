import 'package:flutter/foundation.dart';

@immutable
class ReaderNavigationTarget {
  const ReaderNavigationTarget({
    required this.surahNumber,
    required this.ayahNumber,
    required this.pageNumber,
  });

  final int surahNumber;
  final int ayahNumber;
  final int pageNumber;

  ReaderNavigationTarget copyWith({
    int? surahNumber,
    int? ayahNumber,
    int? pageNumber,
  }) {
    return ReaderNavigationTarget(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ReaderNavigationTarget &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber &&
        other.pageNumber == pageNumber;
  }

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, pageNumber);
}
