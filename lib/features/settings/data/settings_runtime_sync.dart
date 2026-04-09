import 'package:quran_library/quran_library.dart';

import '../domain/app_settings_state.dart';

abstract class SettingsRuntimeSync {
  void sync(AppSettingsState settings);

  void syncTajweed(bool enabled);
}

class QuranLibrarySettingsRuntimeSync implements SettingsRuntimeSync {
  const QuranLibrarySettingsRuntimeSync({
    this.quranCtrl,
    this.surahCtrl,
    this.persistTajweed,
  });

  final QuranCtrl? quranCtrl;
  final SurahCtrl? surahCtrl;
  final void Function(bool enabled)? persistTajweed;

  @override
  void sync(AppSettingsState settings) {
    syncTajweed(settings.tajweedEnabled);
  }

  @override
  void syncTajweed(bool enabled) {
    final activeQuranCtrl = quranCtrl ?? QuranCtrl.instance;
    if (persistTajweed == null) {
      activeQuranCtrl.applyTajweedSetting(enabled);
    } else {
      activeQuranCtrl.state.isTajweedEnabled.value = enabled;
      persistTajweed!(enabled);
      activeQuranCtrl.update();
      activeQuranCtrl.update(['_pageViewBuild']);
    }

    (surahCtrl ?? SurahCtrl.maybeInstance)?.update();
  }
}
