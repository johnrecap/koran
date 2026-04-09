class StoryDataSourceException implements Exception {
  StoryDataSourceException({
    required this.assetPath,
    required this.cause,
    this.stackTrace,
  });

  final String assetPath;
  final Object cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'StoryDataSourceException(assetPath: $assetPath, cause: $cause)';
  }
}
