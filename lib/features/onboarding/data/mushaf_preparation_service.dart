import 'package:quran_library/quran_library.dart';

abstract class MushafPreparationService {
  Future<void> prepare({
    required void Function(double progress) onProgress,
  });
}

class QuranLibraryMushafPreparationService implements MushafPreparationService {
  const QuranLibraryMushafPreparationService();

  @override
  Future<void> prepare({
    required void Function(double progress) onProgress,
  }) async {
    final quranCtrl = QuranCtrl.instance;

    onProgress(0.08);
    await quranCtrl.ensureCoreDataLoaded();

    onProgress(0.38);
    await quranCtrl.ensureQpcV4AllPagesPrebuilt();

    onProgress(0.78);
    await QuranFontsService.loadRemainingInBackground(
      startNearPage: 1,
      progress: quranCtrl.state.fontsLoadProgress,
      ready: quranCtrl.state.fontsReady,
    );

    quranCtrl.state.isFontDownloaded.value = true;
    quranCtrl.state.fontsSelected.value = 0;
    quranCtrl.state.fontsLoadProgress.value = 1.0;
    quranCtrl.state.fontsReady.value = true;

    onProgress(1.0);
  }
}
