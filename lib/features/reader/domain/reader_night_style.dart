enum ReaderNightStyle { night, amoled }

enum ReaderNightPresentation { normal, night, amoled }

abstract final class ReaderNightStylePolicy {
  static const defaultStyle = ReaderNightStyle.night;

  static ReaderNightStyle fromPreference(String? value) {
    switch (value) {
      case 'amoled':
        return ReaderNightStyle.amoled;
      case 'night':
      default:
        return defaultStyle;
    }
  }

  static String toPreference(ReaderNightStyle style) {
    return switch (style) {
      ReaderNightStyle.night => 'night',
      ReaderNightStyle.amoled => 'amoled',
    };
  }

  static ReaderNightPresentation toPresentation(ReaderNightStyle style) {
    return switch (style) {
      ReaderNightStyle.night => ReaderNightPresentation.night,
      ReaderNightStyle.amoled => ReaderNightPresentation.amoled,
    };
  }
}
