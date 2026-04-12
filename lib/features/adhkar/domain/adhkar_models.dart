class AdhkarCatalog {
  const AdhkarCatalog({
    required this.categories,
  });

  final List<AdhkarCategory> categories;

  factory AdhkarCatalog.fromMap(Map<String, dynamic> map) {
    final rawCategories = map['categories'];
    if (rawCategories is! List<dynamic>) {
      throw const FormatException('Adhkar catalog categories are missing.');
    }

    return AdhkarCatalog(
      categories: rawCategories
          .whereType<Map<String, dynamic>>()
          .map(AdhkarCategory.fromMap)
          .toList(growable: false),
    );
  }

  AdhkarCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }
}

class AdhkarCategory {
  const AdhkarCategory({
    required this.id,
    required this.groupId,
    required this.sourceLabel,
    this.sourceNote,
    required this.entries,
  });

  final String id;
  final String groupId;
  final String sourceLabel;
  final String? sourceNote;
  final List<AdhkarEntry> entries;

  factory AdhkarCategory.fromMap(Map<String, dynamic> map) {
    final rawEntries = map['entries'];
    if (rawEntries is! List<dynamic>) {
      throw FormatException(
        'Adhkar category entries are missing for ${map['id']}.',
      );
    }

    return AdhkarCategory(
      id: _requiredString(map, 'id'),
      groupId: _requiredString(map, 'groupId'),
      sourceLabel: _requiredString(map, 'sourceLabel'),
      sourceNote: _optionalString(map['sourceNote']),
      entries: rawEntries
          .whereType<Map<String, dynamic>>()
          .map(AdhkarEntry.fromMap)
          .toList(growable: false),
    );
  }
}

class AdhkarEntry {
  const AdhkarEntry({
    required this.id,
    required this.arabicText,
    this.repetitionCount,
    this.reference,
    this.sourceDetail,
    this.authenticityNote,
    this.timingNote,
    this.virtue,
    this.note,
  });

  final String id;
  final String arabicText;
  final int? repetitionCount;
  final String? reference;
  final String? sourceDetail;
  final String? authenticityNote;
  final String? timingNote;
  final String? virtue;
  final String? note;

  factory AdhkarEntry.fromMap(Map<String, dynamic> map) {
    return AdhkarEntry(
      id: _requiredString(map, 'id'),
      arabicText: _requiredString(map, 'arabicText'),
      repetitionCount: _optionalPositiveInt(map['repetitionCount']),
      reference: _optionalString(map['reference']),
      sourceDetail: _optionalString(map['sourceDetail']),
      authenticityNote: _optionalString(map['authenticityNote']),
      timingNote: _optionalString(map['timingNote']),
      virtue: _optionalString(map['virtue']),
      note: _optionalString(map['note']),
    );
  }
}

String _requiredString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String) {
    throw FormatException('Adhkar catalog field $key is missing.');
  }

  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw FormatException('Adhkar catalog field $key is empty.');
  }

  return normalized;
}

String? _optionalString(Object? value) {
  if (value is! String) {
    return null;
  }

  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

int? _optionalPositiveInt(Object? value) {
  if (value is! int || value <= 0) {
    return null;
  }

  return value;
}
