import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';

class QuranStory {
  const QuranStory({
    required this.id,
    required this.file,
    required this.titleAr,
    required this.titleEn,
    required this.category,
    required this.iconKey,
    required this.summaryAr,
    required this.summaryEn,
    required this.chapterCount,
    required this.totalVerses,
    required this.estimatedReadingMinutes,
    required this.mainSurahsAr,
    required this.mainSurahsNumbers,
    required this.order,
    this.chapters,
  });

  final String id;
  final String? file;
  final String titleAr;
  final String titleEn;
  final StoryCategory category;
  final String iconKey;
  final String summaryAr;
  final String summaryEn;
  final int chapterCount;
  final int totalVerses;
  final int estimatedReadingMinutes;
  final List<String> mainSurahsAr;
  final List<int> mainSurahsNumbers;
  final int? order;
  final List<StoryChapter>? chapters;

  factory QuranStory.fromIndexJson(Map<String, dynamic> json) {
    return QuranStory(
      id: json['id'] as String? ?? '',
      file: json['file'] as String?,
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      category: StoryCategory.fromStorageValue(json['category'] as String?),
      iconKey: json['icon_key'] as String? ?? '',
      summaryAr: json['summary_ar'] as String? ?? '',
      summaryEn: json['summary_en'] as String? ?? '',
      chapterCount: (json['chapter_count'] as num?)?.toInt() ?? 0,
      totalVerses: (json['total_verses'] as num?)?.toInt() ?? 0,
      estimatedReadingMinutes:
          (json['estimated_reading_minutes'] as num?)?.toInt() ?? 0,
      mainSurahsAr: _parseStringList(json['main_surahs_ar']),
      mainSurahsNumbers: _parseIntList(json['main_surahs_numbers']),
      order: (json['order'] as num?)?.toInt(),
    );
  }

  factory QuranStory.fromDetailJson(Map<String, dynamic> json) {
    final chapters = _parseChapterList(json['chapters']);

    return QuranStory(
      id: json['id'] as String? ?? '',
      file: json['file'] as String?,
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      category: StoryCategory.fromStorageValue(json['category'] as String?),
      iconKey: json['icon_key'] as String? ?? '',
      summaryAr: json['summary_ar'] as String? ?? '',
      summaryEn: json['summary_en'] as String? ?? '',
      chapterCount: (json['chapter_count'] as num?)?.toInt() ?? chapters.length,
      totalVerses: (json['total_verses'] as num?)?.toInt() ??
          chapters.fold<int>(
            0,
            (total, chapter) => total + chapter.verses.length,
          ),
      estimatedReadingMinutes:
          (json['estimated_reading_minutes'] as num?)?.toInt() ?? 0,
      mainSurahsAr: _parseStringList(json['main_surahs_ar']),
      mainSurahsNumbers: _parseIntList(json['main_surahs_numbers']),
      order: (json['order'] as num?)?.toInt(),
      chapters: chapters,
    );
  }
}

List<StoryChapter> _parseChapterList(Object? value) {
  final chapterList = value as List<dynamic>? ?? const <dynamic>[];
  return chapterList
      .whereType<Map<String, dynamic>>()
      .map(StoryChapter.fromJson)
      .toList(growable: false);
}

List<String> _parseStringList(Object? value) {
  final items = value as List<dynamic>? ?? const <dynamic>[];
  return items.whereType<String>().toList(growable: false);
}

List<int> _parseIntList(Object? value) {
  final items = value as List<dynamic>? ?? const <dynamic>[];
  return items
      .whereType<num>()
      .map((item) => item.toInt())
      .toList(growable: false);
}
