import 'package:flutter/widgets.dart';

abstract final class AppLocalePolicy {
  static const Locale defaultLocale = Locale('ar');

  static Locale resolve(String? languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en');
      case 'ar':
      default:
        return defaultLocale;
    }
  }
}
