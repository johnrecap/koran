import 'dart:convert';

/// A single reading session — created when user reads in the Mushaf.
class ReadingSession {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final DateTime timestamp;
  final int durationMinutes;
  final String? khatmaId; // null = regular session
  final bool isTrustedKhatmaAnchor;

  ReadingSession({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.timestamp,
    this.durationMinutes = 0,
    this.khatmaId,
    this.isTrustedKhatmaAnchor = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'surahName': surahName,
        'timestamp': timestamp.toIso8601String(),
        'durationMinutes': durationMinutes,
        'khatmaId': khatmaId,
        'isTrustedKhatmaAnchor': isTrustedKhatmaAnchor,
      };

  factory ReadingSession.fromMap(Map<String, dynamic> map) => ReadingSession(
        id: map['id'] as String,
        surahNumber: map['surahNumber'] as int,
        ayahNumber: map['ayahNumber'] as int,
        surahName: map['surahName'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        durationMinutes: map['durationMinutes'] as int? ?? 0,
        khatmaId: map['khatmaId'] as String?,
        isTrustedKhatmaAnchor: map['isTrustedKhatmaAnchor'] as bool? ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory ReadingSession.fromJson(String json) =>
      ReadingSession.fromMap(jsonDecode(json) as Map<String, dynamic>);
}

/// A Khatma — structured plan to complete the Quran.
class Khatma {
  static const int mushafPageCount = 604;

  final String id;
  final String title;
  final int targetDays;
  final DateTime startDate;
  final DateTime? completedDate;
  final int completedSurahs; // count of completed surahs in this khatma
  final int startPage;
  final int furthestPageRead;
  final int totalReadMinutes;
  final List<String> readingDayKeys;

  Khatma({
    required this.id,
    required this.title,
    required this.targetDays,
    required this.startDate,
    this.completedDate,
    this.completedSurahs = 0,
    this.startPage = 1,
    this.furthestPageRead = 0,
    this.totalReadMinutes = 0,
    this.readingDayKeys = const <String>[],
  });

  bool get isCompleted => completedDate != null;
  double get progress {
    if (furthestPageRead > 0) {
      return (furthestPageRead / mushafPageCount).clamp(0.0, 1.0);
    }

    return (completedSurahs / 114).clamp(0.0, 1.0);
  }

  /// Days elapsed since [startDate] using the caller-provided clock value.
  int daysElapsed(DateTime now) => now.difference(startDate).inDays;

  /// Days remaining in the plan using the caller-provided clock value.
  int daysRemaining(DateTime now) {
    final elapsed = daysElapsed(now);
    return (targetDays - elapsed).clamp(0, targetDays);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'targetDays': targetDays,
        'startDate': startDate.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'completedSurahs': completedSurahs,
        'startPage': startPage,
        'furthestPageRead': furthestPageRead,
        'totalReadMinutes': totalReadMinutes,
        'readingDayKeys': readingDayKeys,
      };

  factory Khatma.fromMap(Map<String, dynamic> map) => Khatma(
        id: map['id'] as String,
        title: map['title'] as String,
        targetDays: map['targetDays'] as int,
        startDate: DateTime.parse(map['startDate'] as String),
        completedDate: map['completedDate'] != null
            ? DateTime.parse(map['completedDate'] as String)
            : null,
        completedSurahs: map['completedSurahs'] as int? ?? 0,
        startPage: map['startPage'] as int? ?? 1,
        furthestPageRead: map['furthestPageRead'] as int? ?? 0,
        totalReadMinutes: map['totalReadMinutes'] as int? ?? 0,
        readingDayKeys: (map['readingDayKeys'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
      );

  Khatma copyWith({
    int? completedSurahs,
    DateTime? completedDate,
    bool clearCompletedDate = false,
    int? startPage,
    int? furthestPageRead,
    int? totalReadMinutes,
    List<String>? readingDayKeys,
  }) =>
      Khatma(
        id: id,
        title: title,
        targetDays: targetDays,
        startDate: startDate,
        completedDate:
            clearCompletedDate ? null : completedDate ?? this.completedDate,
        completedSurahs: completedSurahs ?? this.completedSurahs,
        startPage: startPage ?? this.startPage,
        furthestPageRead: furthestPageRead ?? this.furthestPageRead,
        totalReadMinutes: totalReadMinutes ?? this.totalReadMinutes,
        readingDayKeys: readingDayKeys ?? this.readingDayKeys,
      );
}
