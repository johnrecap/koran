import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

abstract final class MuallimPageSyncPolicy {
  static bool shouldNavigate({
    required bool isEnabled,
    required ReaderMode readerMode,
    required int currentDisplayedPage,
    required int? currentAyahPage,
  }) {
    if (!isEnabled || currentAyahPage == null) {
      return false;
    }

    if (readerMode != ReaderMode.scroll) {
      return false;
    }

    return currentAyahPage != currentDisplayedPage;
  }
}
