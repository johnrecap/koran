enum StoryCategory {
  prophets('prophets'),
  quranic('quranic');

  const StoryCategory(this.storageValue);

  final String storageValue;

  static StoryCategory fromStorageValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final category in StoryCategory.values) {
      if (category.storageValue == normalized) {
        return category;
      }
    }

    return StoryCategory.quranic;
  }
}
