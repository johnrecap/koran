class TafsirBrowserSourceOption {
  const TafsirBrowserSourceOption({
    required this.id,
    required this.title,
    required this.bookName,
    required this.isTranslation,
    required this.isSelected,
    required this.isDownloaded,
  });

  final String id;
  final String title;
  final String bookName;
  final bool isTranslation;
  final bool isSelected;
  final bool isDownloaded;

  TafsirBrowserSourceOption copyWith({
    String? id,
    String? title,
    String? bookName,
    bool? isTranslation,
    bool? isSelected,
    bool? isDownloaded,
  }) {
    return TafsirBrowserSourceOption(
      id: id ?? this.id,
      title: title ?? this.title,
      bookName: bookName ?? this.bookName,
      isTranslation: isTranslation ?? this.isTranslation,
      isSelected: isSelected ?? this.isSelected,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TafsirBrowserSourceOption &&
            other.id == id &&
            other.title == title &&
            other.bookName == bookName &&
            other.isTranslation == isTranslation &&
            other.isSelected == isSelected &&
            other.isDownloaded == isDownloaded);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        bookName,
        isTranslation,
        isSelected,
        isDownloaded,
      );
}
