enum InsightSectionType {
  tafsir,
  wordMeaning,
  asbaabAlNuzul,
  relatedAyahs,
}

sealed class InsightSectionData {
  const InsightSectionData();
}

class InsightSectionLoaded<T> extends InsightSectionData {
  const InsightSectionLoaded(this.content);

  final T content;
}

class InsightSectionUnavailable extends InsightSectionData {
  const InsightSectionUnavailable();
}

class InsightSectionError extends InsightSectionData {
  const InsightSectionError(this.error);

  final Object error;
}

class WordMeaningEntry {
  const WordMeaningEntry({
    required this.word,
    required this.meaning,
    this.root,
  });

  factory WordMeaningEntry.fromMap(Map<String, dynamic> map) {
    return WordMeaningEntry(
      word: _readRequiredString(map, 'word'),
      meaning: _readRequiredString(map, 'meaning'),
      root: _readOptionalString(map, 'root'),
    );
  }

  final String word;
  final String meaning;
  final String? root;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is WordMeaningEntry &&
            other.word == word &&
            other.meaning == meaning &&
            other.root == root);
  }

  @override
  int get hashCode => Object.hash(word, meaning, root);
}

class AsbaabEntry {
  const AsbaabEntry({
    required this.text,
    required this.source,
    this.narrator,
  });

  factory AsbaabEntry.fromMap(Map<String, dynamic> map) {
    return AsbaabEntry(
      text: _readRequiredString(map, 'text'),
      source: _readRequiredString(map, 'source'),
      narrator: _readOptionalString(map, 'narrator'),
    );
  }

  final String text;
  final String source;
  final String? narrator;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AsbaabEntry &&
            other.text == text &&
            other.source == source &&
            other.narrator == narrator);
  }

  @override
  int get hashCode => Object.hash(text, source, narrator);
}

class RelatedAyahEntry {
  const RelatedAyahEntry({
    required this.surahNumber,
    required this.ayahNumber,
    required this.tag,
    this.snippet,
  });

  factory RelatedAyahEntry.fromMap(Map<String, dynamic> map) {
    return RelatedAyahEntry(
      surahNumber: _readRequiredInt(map, const ['surahNumber', 'surah']),
      ayahNumber: _readRequiredInt(map, const ['ayahNumber', 'ayah']),
      tag: _readRequiredString(map, 'tag'),
      snippet: _readOptionalString(map, 'snippet'),
    );
  }

  final int surahNumber;
  final int ayahNumber;
  final String tag;
  final String? snippet;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RelatedAyahEntry &&
            other.surahNumber == surahNumber &&
            other.ayahNumber == ayahNumber &&
            other.tag == tag &&
            other.snippet == snippet);
  }

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, tag, snippet);
}

String _readRequiredString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  throw FormatException('Missing or invalid "$key" string.');
}

String? _readOptionalString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }

  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  return null;
}

int _readRequiredInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }

  throw FormatException(
    'Missing or invalid integer for any of: ${keys.join(', ')}.',
  );
}
