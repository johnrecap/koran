class StoryVerse {
  const StoryVerse({
    required this.surah,
    required this.ayahStart,
    required this.ayahEnd,
    required this.textAr,
    required this.contextAr,
  });

  final int surah;
  final int ayahStart;
  final int ayahEnd;
  final String textAr;
  final String contextAr;

  bool get isRange => ayahStart != ayahEnd;

  factory StoryVerse.fromJson(Map<String, dynamic> json) {
    return StoryVerse(
      surah: (json['surah'] as num?)?.toInt() ?? 0,
      ayahStart: (json['ayah_start'] as num?)?.toInt() ?? 0,
      ayahEnd: (json['ayah_end'] as num?)?.toInt() ?? 0,
      textAr: json['text_ar'] as String? ?? '',
      contextAr: json['context_ar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'surah': surah,
        'ayah_start': ayahStart,
        'ayah_end': ayahEnd,
        'text_ar': textAr,
        'context_ar': contextAr,
      };
}
