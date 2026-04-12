class VerseIdentifier {
  const VerseIdentifier({
    required this.surah,
    required this.ayah,
  });

  final int surah;
  final int ayah;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VerseIdentifier &&
            other.surah == surah &&
            other.ayah == ayah);
  }

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => '$surah:$ayah';
}
