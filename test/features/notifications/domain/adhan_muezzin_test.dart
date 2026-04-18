import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';

void main() {
  test('exposes stable CDN urls and cache file names', () {
    expect(
      AdhanMuezzin.misharyAlafasy.cdnUrl,
      'https://cdn.aladhan.com/audio/adhans/a9.mp3',
    );
    expect(
      AdhanMuezzin.misharyAlafasy.cacheFileName,
      'misharyAlafasy.mp3',
    );
    expect(
      AdhanMuezzin.mansourAlZahrani.cdnUrl,
      'https://cdn.aladhan.com/audio/adhans/a11-mansour-al-zahrani.mp3',
    );
  });

  test('parses muezzins from names with a safe fallback', () {
    expect(
      AdhanMuezzin.fromName('mansourAlZahrani'),
      AdhanMuezzin.mansourAlZahrani,
    );
    expect(
      AdhanMuezzin.fromName('missing'),
      AdhanMuezzin.misharyAlafasy,
    );
    expect(
      AdhanMuezzin.fromName(null),
      AdhanMuezzin.misharyAlafasy,
    );
  });

  test('resolves localized labels for Arabic and English', () {
    final english = AppLocalizations(const Locale('en'));
    final arabic = AppLocalizations(const Locale('ar'));

    expect(
      AdhanMuezzin.misharyAlafasy.label(english),
      'Mishary Rashid Al-Afasy',
    );
    expect(
      AdhanMuezzin.misharyAlafasy.label(arabic),
      'مشاري راشد العفاسي',
    );
    expect(
      AdhanMuezzin.ahmedAlNafis.label(english),
      'Ahmad Al-Nafees',
    );
    expect(
      AdhanMuezzin.ahmedAlNafis.label(arabic),
      'أحمد النفيس',
    );
  });
}
