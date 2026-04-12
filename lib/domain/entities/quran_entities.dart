/// Represents a Surah (chapter) of the Quran
class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final int ayahCount;
  final String revelationType; // 'Meccan' or 'Medinan'
  final int page; // Starting page in Mushaf

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.ayahCount,
    required this.revelationType,
    required this.page,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      number: map['id'] as int,
      nameArabic: map['name_arabic'] as String,
      nameEnglish:
          map['name_simple'] as String? ?? map['name_english'] as String? ?? '',
      nameTransliteration: map['name_transliteration'] as String? ?? '',
      ayahCount: map['ayah_count'] as int? ?? map['verses_count'] as int? ?? 0,
      revelationType: map['revelation_type'] as String? ?? 'Meccan',
      page: map['page'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Surah &&
            number == other.number &&
            nameArabic == other.nameArabic &&
            nameEnglish == other.nameEnglish &&
            nameTransliteration == other.nameTransliteration &&
            ayahCount == other.ayahCount &&
            revelationType == other.revelationType &&
            page == other.page;
  }

  @override
  int get hashCode => Object.hash(
        number,
        nameArabic,
        nameEnglish,
        nameTransliteration,
        ayahCount,
        revelationType,
        page,
      );
}

/// Represents a single Ayah (verse)
class Ayah {
  final int id; // Unique ID across the Quran (1-6236)
  final int surahNumber;
  final int ayahNumber; // Verse number within the surah
  final String text; // Uthmani text
  final int page;
  final int juz;
  final int hizb;

  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.page,
    required this.juz,
    required this.hizb,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      id: map['id'] as int? ?? 0,
      surahNumber: map['sura'] as int? ?? map['surah_number'] as int? ?? 0,
      ayahNumber: map['aya'] as int? ?? map['ayah_number'] as int? ?? 0,
      text: map['text'] as String? ?? '',
      page: map['page'] as int? ?? 1,
      juz: map['juz'] as int? ?? 1,
      hizb: map['hizb'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Ayah &&
            id == other.id &&
            surahNumber == other.surahNumber &&
            ayahNumber == other.ayahNumber &&
            text == other.text &&
            page == other.page &&
            juz == other.juz &&
            hizb == other.hizb;
  }

  @override
  int get hashCode => Object.hash(
        id,
        surahNumber,
        ayahNumber,
        text,
        page,
        juz,
        hizb,
      );
}

/// Represents a Bookmark
class Bookmark {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String name;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.name,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Bookmark &&
            id == other.id &&
            surahNumber == other.surahNumber &&
            ayahNumber == other.ayahNumber &&
            name == other.name &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        surahNumber,
        ayahNumber,
        name,
        createdAt,
      );
}

/// Represents a user Note on an Ayah
class AyahNote {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AyahNote({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AyahNote &&
            id == other.id &&
            surahNumber == other.surahNumber &&
            ayahNumber == other.ayahNumber &&
            content == other.content &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        surahNumber,
        ayahNumber,
        content,
        createdAt,
        updatedAt,
      );
}

/// Reading position for saving/restoring
class ReadingPosition {
  final int surahNumber;
  final int ayahNumber;
  final int page;
  final DateTime savedAt;

  const ReadingPosition({
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'page': page,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory ReadingPosition.fromMap(Map<String, dynamic> map) {
    return ReadingPosition(
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
      page: map['page'] as int? ?? 1,
      savedAt: DateTime.parse(map['savedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReadingPosition &&
            surahNumber == other.surahNumber &&
            ayahNumber == other.ayahNumber &&
            page == other.page &&
            savedAt == other.savedAt;
  }

  @override
  int get hashCode => Object.hash(
        surahNumber,
        ayahNumber,
        page,
        savedAt,
      );
}
