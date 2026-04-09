class StoryReadingProgress {
  const StoryReadingProgress({
    required this.storyId,
    required this.lastChapterIndex,
    this.completedAt,
  });

  final String storyId;
  final int lastChapterIndex;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  double completionPercent(int totalChapters) {
    if (totalChapters <= 0) {
      return 0;
    }
    if (isCompleted) {
      return 100;
    }

    final completedChapters = lastChapterIndex + 1;
    final percent = (completedChapters / totalChapters) * 100;
    return percent.clamp(0, 100).toDouble();
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'storyId': storyId,
        'lastChapterIndex': lastChapterIndex,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory StoryReadingProgress.fromMap(Map<String, dynamic> map) {
    return StoryReadingProgress(
      storyId: map['storyId'] as String? ?? '',
      lastChapterIndex: (map['lastChapterIndex'] as num?)?.toInt() ?? 0,
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.tryParse(map['completedAt'] as String),
    );
  }
}
