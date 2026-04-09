import 'dart:convert';

enum ReviewOutcome { easy, medium, hard }

class SpacedReviewItem {
  const SpacedReviewItem({
    required this.id,
    required this.khatmaId,
    required this.khatmaTitle,
    required this.startPage,
    required this.endPage,
    required this.createdAt,
    required this.nextReviewAt,
    this.lastReviewedAt,
    required this.repetitionCount,
    required this.intervalDays,
    required this.easeFactor,
    this.lastOutcome,
  });

  final String id;
  final String khatmaId;
  final String khatmaTitle;
  final int startPage;
  final int endPage;
  final DateTime createdAt;
  final DateTime nextReviewAt;
  final DateTime? lastReviewedAt;
  final int repetitionCount;
  final int intervalDays;
  final double easeFactor;
  final ReviewOutcome? lastOutcome;

  static String buildId({
    required String khatmaId,
    required int startPage,
    required int endPage,
  }) {
    return '${khatmaId}_${startPage}_$endPage';
  }

  bool matchesRange({
    required String khatmaId,
    required int startPage,
    required int endPage,
  }) {
    return this.khatmaId == khatmaId &&
        this.startPage == startPage &&
        this.endPage == endPage;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'khatmaId': khatmaId,
        'khatmaTitle': khatmaTitle,
        'startPage': startPage,
        'endPage': endPage,
        'createdAt': createdAt.toIso8601String(),
        'nextReviewAt': nextReviewAt.toIso8601String(),
        'lastReviewedAt': lastReviewedAt?.toIso8601String(),
        'repetitionCount': repetitionCount,
        'intervalDays': intervalDays,
        'easeFactor': easeFactor,
        'lastOutcome': lastOutcome?.name,
      };

  factory SpacedReviewItem.fromMap(Map<String, dynamic> map) {
    return SpacedReviewItem(
      id: map['id'] as String,
      khatmaId: map['khatmaId'] as String,
      khatmaTitle: map['khatmaTitle'] as String? ?? '',
      startPage: map['startPage'] as int,
      endPage: map['endPage'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      nextReviewAt: DateTime.parse(map['nextReviewAt'] as String),
      lastReviewedAt: map['lastReviewedAt'] == null
          ? null
          : DateTime.parse(map['lastReviewedAt'] as String),
      repetitionCount: map['repetitionCount'] as int? ?? 0,
      intervalDays: map['intervalDays'] as int? ?? 1,
      easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.3,
      lastOutcome: _reviewOutcomeFromName(map['lastOutcome'] as String?),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SpacedReviewItem.fromJson(String json) {
    return SpacedReviewItem.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  SpacedReviewItem copyWith({
    String? khatmaTitle,
    DateTime? nextReviewAt,
    DateTime? lastReviewedAt,
    bool clearLastReviewedAt = false,
    int? repetitionCount,
    int? intervalDays,
    double? easeFactor,
    ReviewOutcome? lastOutcome,
    bool clearLastOutcome = false,
  }) {
    return SpacedReviewItem(
      id: id,
      khatmaId: khatmaId,
      khatmaTitle: khatmaTitle ?? this.khatmaTitle,
      startPage: startPage,
      endPage: endPage,
      createdAt: createdAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt:
          clearLastReviewedAt ? null : lastReviewedAt ?? this.lastReviewedAt,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      lastOutcome: clearLastOutcome ? null : lastOutcome ?? this.lastOutcome,
    );
  }
}

ReviewOutcome? _reviewOutcomeFromName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  for (final outcome in ReviewOutcome.values) {
    if (outcome.name == value) {
      return outcome;
    }
  }

  return null;
}
