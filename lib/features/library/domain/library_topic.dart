import 'package:quran_kareem/domain/entities/quran_entities.dart';

enum LibraryTopicCategory {
  all,
  stories,
  laws,
  afterlife;

  static LibraryTopicCategory fromStorageValue(String value) {
    switch (value) {
      case 'stories':
        return LibraryTopicCategory.stories;
      case 'laws':
        return LibraryTopicCategory.laws;
      case 'afterlife':
        return LibraryTopicCategory.afterlife;
      default:
        return LibraryTopicCategory.all;
    }
  }
}

class LibraryTopicReference {
  const LibraryTopicReference({
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  factory LibraryTopicReference.fromVerseKey(String verseKey) {
    final parts = verseKey.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid verse key');
    }

    return LibraryTopicReference(
      surahNumber: int.parse(parts[0]),
      ayahNumber: int.parse(parts[1]),
    );
  }
}

class LibraryTopic {
  const LibraryTopic({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionArabic,
    required this.descriptionEnglish,
    required this.category,
    required this.iconKey,
    required this.references,
  });

  final String id;
  final String titleArabic;
  final String titleEnglish;
  final String descriptionArabic;
  final String descriptionEnglish;
  final LibraryTopicCategory category;
  final String iconKey;
  final List<LibraryTopicReference> references;

  factory LibraryTopic.fromMap(Map<String, dynamic> map) {
    final rawReferences = map['references'] as List<dynamic>? ?? const [];
    return LibraryTopic(
      id: map['id'] as String? ?? '',
      titleArabic: map['title_ar'] as String? ?? '',
      titleEnglish: map['title_en'] as String? ?? '',
      descriptionArabic: map['description_ar'] as String? ?? '',
      descriptionEnglish: map['description_en'] as String? ?? '',
      category: LibraryTopicCategory.fromStorageValue(
        map['category'] as String? ?? '',
      ),
      iconKey: map['icon_key'] as String? ?? 'menu_book',
      references: rawReferences
          .whereType<String>()
          .map(LibraryTopicReference.fromVerseKey)
          .toList(growable: false),
    );
  }

  String localizedTitle(String languageCode) {
    return languageCode == 'ar' ? titleArabic : titleEnglish;
  }

  String localizedDescription(String languageCode) {
    return languageCode == 'ar' ? descriptionArabic : descriptionEnglish;
  }

  bool matchesQuery(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return true;
    }

    final lowercase = normalized.toLowerCase();
    return titleArabic.contains(normalized) ||
        descriptionArabic.contains(normalized) ||
        titleEnglish.toLowerCase().contains(lowercase) ||
        descriptionEnglish.toLowerCase().contains(lowercase);
  }
}

class LibraryTopicReferenceResult {
  const LibraryTopicReferenceResult({
    required this.ayah,
    required this.surahName,
  });

  final Ayah ayah;
  final String surahName;
}
