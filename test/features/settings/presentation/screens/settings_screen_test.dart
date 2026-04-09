import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';
import 'package:quran_kareem/features/settings/presentation/screens/settings_screen.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

void main() {
  testWidgets('renders localized settings copy for arabic and english locales',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        initialSettings: const AppSettingsState(
          themeMode: ThemeMode.light,
          locale: Locale('ar'),
          arabicFontSize: 28,
          defaultReaderMode: ReaderMode.scroll,
          tajweedEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('الإنجليزية'), findsOneWidget);

    await tester.pumpWidget(
      _buildHarness(
        initialSettings: const AppSettingsState(
          themeMode: ThemeMode.light,
          locale: Locale('en'),
          arabicFontSize: 28,
          defaultReaderMode: ReaderMode.scroll,
          tajweedEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
  });

  testWidgets('renders live preview and all settings controls', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        initialSettings: const AppSettingsState(
          themeMode: ThemeMode.light,
          locale: Locale('en'),
          arabicFontSize: 28,
          defaultReaderMode: ReaderMode.scroll,
          tajweedEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-preview-card')), findsOneWidget);
    expect(find.byKey(const Key('settings-theme-dark-option')), findsOneWidget);
    expect(
        find.byKey(const Key('settings-language-en-option')), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-font-size-slider')), findsOneWidget);
    expect(find.byKey(const Key('settings-reader-mode-page-option')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-tajweed-switch')), findsOneWidget);
  });

  testWidgets('updates unified settings state from screen interactions',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        initialSettings: const AppSettingsState(
          themeMode: ThemeMode.light,
          locale: Locale('ar'),
          arabicFontSize: 28,
          defaultReaderMode: ReaderMode.scroll,
          tajweedEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );

    await tester.tap(find.byKey(const Key('settings-theme-dark-option')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-language-en-option')));
    await tester.pump();
    final pageModeFinder =
        find.byKey(const Key('settings-reader-mode-page-option'));
    await tester.ensureVisible(pageModeFinder);
    await tester.pumpAndSettle();
    await tester.tap(pageModeFinder);
    await tester.pump();

    final sliderFinder = find.byKey(const Key('settings-font-size-slider'));
    await tester.ensureVisible(sliderFinder);
    await tester.pumpAndSettle();
    final slider = tester.widget<Slider>(sliderFinder);
    slider.onChanged?.call(34);
    await tester.pump();

    final tajweedFinder = find.byKey(const Key('settings-tajweed-switch'));
    await tester.ensureVisible(tajweedFinder);
    await tester.pumpAndSettle();
    await tester.tap(tajweedFinder);
    await tester.pumpAndSettle();

    final state = container.read(appSettingsControllerProvider);
    expect(state.themeMode, ThemeMode.dark);
    expect(state.locale, const Locale('en'));
    expect(state.arabicFontSize, 34);
    expect(state.defaultReaderMode, ReaderMode.page);
    expect(state.tajweedEnabled, isTrue);
  });

  testWidgets(
      'shows a notifications entry and pushes the notifications settings route',
      (tester) async {
    await tester.pumpWidget(
      _buildRouterHarness(
        initialSettings: const AppSettingsState(
          themeMode: ThemeMode.light,
          locale: Locale('en'),
          arabicFontSize: 28,
          defaultReaderMode: ReaderMode.scroll,
          tajweedEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final notificationsEntry =
        find.byKey(const Key('settings-notifications-entry'));
    await tester.scrollUntilVisible(
      notificationsEntry,
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(notificationsEntry, findsOneWidget);

    await tester.ensureVisible(notificationsEntry);
    await tester.tap(notificationsEntry);
    await tester.pumpAndSettle();

    expect(find.text('Notifications Route'), findsOneWidget);
  });

  testWidgets('renders the night reader section summary and time controls',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        initialSettings: const AppSettingsState(
          themeMode: ThemeMode.light,
          locale: Locale('en'),
          arabicFontSize: 28,
          defaultReaderMode: ReaderMode.scroll,
          tajweedEnabled: false,
          nightReaderSettings: NightReaderSettings(
            autoEnable: true,
            startMinutes: 21 * 60,
            endMinutes: (4 * 60) + 30,
            preferredStyle: ReaderNightStyle.amoled,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-night-reader-section')), findsOneWidget);
    expect(find.byKey(const Key('settings-night-reader-auto-enable-switch')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-night-reader-start-tile')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-night-reader-end-tile')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-night-reader-summary')), findsOneWidget);
    expect(find.textContaining('AMOLED'), findsOneWidget);
    expect(find.text('9:00 PM'), findsWidgets);
    expect(find.text('4:30 AM'), findsWidgets);
  });
}

Widget _buildHarness({
  required AppSettingsState initialSettings,
}) {
  return ProviderScope(
    overrides: [
      appSettingsInitialStateProvider.overrideWithValue(initialSettings),
    ],
    child: MaterialApp(
      locale: initialSettings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const SettingsScreen(),
    ),
  );
}

Widget _buildRouterHarness({
  required AppSettingsState initialSettings,
}) {
  return ProviderScope(
    overrides: [
      appSettingsInitialStateProvider.overrideWithValue(initialSettings),
    ],
    child: MaterialApp.router(
      locale: initialSettings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/more/settings',
        routes: [
          GoRoute(
            path: '/more/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/more/settings/notifications',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Notifications Route'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
