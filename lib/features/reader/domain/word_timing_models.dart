import 'package:flutter/foundation.dart';

/// A single word's timing segment within an ayah.
/// [wordIndex] is 0-based within the ayah.
/// [startMs] and [endMs] are milliseconds from the start of the surah audio.
@immutable
class WordTimingSegment {
  const WordTimingSegment({
    required this.wordIndex,
    required this.startMs,
    required this.endMs,
  });

  final int wordIndex;
  final int startMs;
  final int endMs;

  /// Whether the given [positionMs] falls within this word's timing window.
  bool contains(int positionMs) =>
      positionMs >= startMs && positionMs <= endMs;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordTimingSegment &&
        other.wordIndex == wordIndex &&
        other.startMs == startMs &&
        other.endMs == endMs;
  }

  @override
  int get hashCode => Object.hash(wordIndex, startMs, endMs);

  @override
  String toString() =>
      'WordTimingSegment(word: $wordIndex, $startMs–$endMs ms)';
}

/// Timing data for all words in a single ayah.
/// [verseKey] is in "surah:ayah" format, e.g. "1:1".
/// [timestampFrom] / [timestampTo] bound the entire ayah in the surah audio.
/// [segments] may be empty if word-level data is unavailable for this ayah.
@immutable
class AyahTimingData {
  const AyahTimingData({
    required this.verseKey,
    required this.surahNumber,
    required this.ayahNumber,
    required this.timestampFrom,
    required this.timestampTo,
    required this.segments,
  });

  final String verseKey;
  final int surahNumber;
  final int ayahNumber;
  final int timestampFrom;
  final int timestampTo;
  final List<WordTimingSegment> segments;

  bool get hasWordSegments => segments.isNotEmpty;

  /// Returns the word index active at [positionMs], or null if none matches.
  int? activeWordIndexAt(int positionMs) {
    for (final seg in segments) {
      if (seg.contains(positionMs)) return seg.wordIndex;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AyahTimingData &&
        other.verseKey == verseKey &&
        other.timestampFrom == timestampFrom &&
        other.timestampTo == timestampTo;
  }

  @override
  int get hashCode => Object.hash(verseKey, timestampFrom, timestampTo);
}

/// Complete timing dataset for a surah, keyed by a specific reciter.
@immutable
class SurahTimingData {
  const SurahTimingData({
    required this.surahNumber,
    required this.reciterId,
    required this.audioUrl,
    required this.ayahTimings,
    required this.hasWordSegments,
  });

  /// An empty/unavailable result — timing data could not be fetched.
  const SurahTimingData.unavailable({
    required this.surahNumber,
    required this.reciterId,
  })  : audioUrl = '',
        ayahTimings = const [],
        hasWordSegments = false;

  final int surahNumber;
  final String reciterId;
  final String audioUrl;
  final List<AyahTimingData> ayahTimings;

  /// True when at least one ayah has word segments.
  final bool hasWordSegments;

  bool get isAvailable => ayahTimings.isNotEmpty;

  /// Returns the [AyahTimingData] for [ayahNumber], or null if not found.
  AyahTimingData? forAyah(int ayahNumber) {
    for (final t in ayahTimings) {
      if (t.ayahNumber == ayahNumber) return t;
    }
    return null;
  }

  /// Returns the ayah active at [positionMs] in the surah audio, or null.
  AyahTimingData? activeAyahAt(int positionMs) {
    for (final t in ayahTimings) {
      if (positionMs >= t.timestampFrom && positionMs <= t.timestampTo) {
        return t;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurahTimingData &&
        other.surahNumber == surahNumber &&
        other.reciterId == reciterId;
  }

  @override
  int get hashCode => Object.hash(surahNumber, reciterId);
}
