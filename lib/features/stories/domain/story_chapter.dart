import 'package:quran_kareem/features/stories/domain/story_verse.dart';

class StoryChapter {
  const StoryChapter({
    required this.id,
    required this.order,
    required this.titleAr,
    required this.titleEn,
    required this.narrativeAr,
    required this.lessonAr,
    required this.lessonEn,
    required this.verses,
  });

  final String id;
  final int order;
  final String titleAr;
  final String titleEn;
  final String narrativeAr;
  final String lessonAr;
  final String lessonEn;
  final List<StoryVerse> verses;

  factory StoryChapter.fromJson(Map<String, dynamic> json) {
    final verseList = json['verses'] as List<dynamic>? ?? const <dynamic>[];

    return StoryChapter(
      id: json['id'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      narrativeAr: json['narrative_ar'] as String? ?? '',
      lessonAr: json['lesson_ar'] as String? ?? '',
      lessonEn: json['lesson_en'] as String? ?? '',
      verses: verseList
          .whereType<Map<String, dynamic>>()
          .map(StoryVerse.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'order': order,
        'title_ar': titleAr,
        'title_en': titleEn,
        'narrative_ar': narrativeAr,
        'lesson_ar': lessonAr,
        'lesson_en': lessonEn,
        'verses': verses.map((verse) => verse.toJson()).toList(growable: false),
      };
}
