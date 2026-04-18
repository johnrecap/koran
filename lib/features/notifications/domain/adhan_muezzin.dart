import 'package:quran_kareem/core/localization/app_localizations.dart';

enum AdhanMuezzin {
  misharyAlafasy(
    cdnUrl: 'https://cdn.aladhan.com/audio/adhans/a9.mp3',
    cacheStem: 'misharyAlafasy',
  ),
  ahmedAlNafis(
    cdnUrl: 'https://cdn.aladhan.com/audio/adhans/a1.mp3',
    cacheStem: 'ahmedAlNafis',
  ),
  hafizMustafaOzcan(
    cdnUrl: 'https://cdn.aladhan.com/audio/adhans/a2.mp3',
    cacheStem: 'hafizMustafaOzcan',
  ),
  alafasyDubai(
    cdnUrl: 'https://cdn.aladhan.com/audio/adhans/a4.mp3',
    cacheStem: 'alafasyDubai',
  ),
  alafasyAlt(
    cdnUrl: 'https://cdn.aladhan.com/audio/adhans/a7.mp3',
    cacheStem: 'alafasyAlt',
  ),
  mansourAlZahrani(
    cdnUrl: 'https://cdn.aladhan.com/audio/adhans/a11-mansour-al-zahrani.mp3',
    cacheStem: 'mansourAlZahrani',
  );

  const AdhanMuezzin({
    required this.cdnUrl,
    required this.cacheStem,
  });

  final String cdnUrl;
  final String cacheStem;

  String get cacheFileName => '$cacheStem.mp3';

  String label(AppLocalizations l10n) {
    return switch (this) {
      AdhanMuezzin.misharyAlafasy =>
        l10n.notificationsAdhanMuezzinMisharyAlafasy,
      AdhanMuezzin.ahmedAlNafis => l10n.notificationsAdhanMuezzinAhmedAlNafis,
      AdhanMuezzin.hafizMustafaOzcan =>
        l10n.notificationsAdhanMuezzinHafizMustafaOzcan,
      AdhanMuezzin.alafasyDubai => l10n.notificationsAdhanMuezzinAlafasyDubai,
      AdhanMuezzin.alafasyAlt => l10n.notificationsAdhanMuezzinAlafasyAlt,
      AdhanMuezzin.mansourAlZahrani =>
        l10n.notificationsAdhanMuezzinMansourAlZahrani,
    };
  }

  static AdhanMuezzin fromName(String? name) {
    return AdhanMuezzin.values.firstWhere(
      (value) => value.name == name,
      orElse: () => AdhanMuezzin.misharyAlafasy,
    );
  }
}
