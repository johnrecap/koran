import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';
import 'package:quran_kareem/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mushafSetupComplete': true,
    });
  });

  group('QuranKareemApp bootstrap', () {
    testWidgets('uses the provided startup locale', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AppSettingsState(
            themeMode: ThemeMode.system,
            locale: Locale('en'),
            arabicFontSize: 28,
            defaultReaderMode: ReaderMode.scroll,
            tajweedEnabled: false,
          ),
        ),
      );

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.locale, const Locale('en'));
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('lets material app derive english directionality', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          const AppSettingsState(
            themeMode: ThemeMode.system,
            locale: Locale('en'),
            arabicFontSize: 28,
            defaultReaderMode: ReaderMode.scroll,
            tajweedEnabled: false,
          ),
        ),
      );
      await tester.pump();

      expect(
        Directionality.of(tester.element(find.byType(Scaffold).first)),
        TextDirection.ltr,
      );
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('uses the provided startup theme mode', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AppSettingsState(
            themeMode: ThemeMode.dark,
            locale: Locale('en'),
            arabicFontSize: 28,
            defaultReaderMode: ReaderMode.scroll,
            tajweedEnabled: false,
          ),
        ),
      );

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('reacts to settings theme changes during the same session',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AppSettingsState(
            themeMode: ThemeMode.light,
            locale: Locale('en'),
            arabicFontSize: 28,
            defaultReaderMode: ReaderMode.scroll,
            tajweedEnabled: false,
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QuranKareemApp)),
      );

      await container
          .read(appSettingsControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('reacts to settings locale changes during the same session',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          const AppSettingsState(
            themeMode: ThemeMode.system,
            locale: Locale('ar'),
            arabicFontSize: 28,
            defaultReaderMode: ReaderMode.scroll,
            tajweedEnabled: false,
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QuranKareemApp)),
      );

      await container
          .read(appSettingsControllerProvider.notifier)
          .setLocale(const Locale('en'));
      await tester.pump();
      await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.locale, const Locale('en'));
      expect(
        Directionality.of(tester.element(find.byType(Scaffold).first)),
        TextDirection.ltr,
      );
    });
  });
}

Widget _buildApp(AppSettingsState initialSettings) {
  return ProviderScope(
    overrides: [
      appSettingsInitialStateProvider.overrideWithValue(initialSettings),
    ],
    child: const QuranKareemApp(),
  );
}
