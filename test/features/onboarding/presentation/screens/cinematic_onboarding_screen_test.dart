import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/onboarding/presentation/screens/cinematic_onboarding_screen.dart';
import 'package:quran_kareem/features/onboarding/presentation/screens/mushaf_setup_screen.dart';
import 'package:quran_kareem/features/onboarding/providers/onboarding_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('advances through the scenes and starts the app when ready',
      (tester) async {
    final service = _ImmediatePreparationService();

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Read as you like'), findsOneWidget);

    await _advanceToNextScene(tester);
    expect(find.text('Listen with focus'), findsOneWidget);

    await _advanceToNextScene(tester);
    await _advanceToNextScene(tester);
    await _advanceToNextScene(tester);

    expect(find.text('Begin your journey'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-start-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-start-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Library Route'), findsOneWidget);
    expect(await UserPreferences.isOnboardingComplete(), isTrue);
  });

  testWidgets(
      'skip sends the user to the loading bridge until preparation finishes',
      (tester) async {
    final service = _ControlledPreparationService();

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('onboarding-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-skip-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('mushaf-setup-bridge')), findsOneWidget);

    service.emitProgress(1.0);
    service.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Library Route'), findsOneWidget);
    expect(await UserPreferences.isOnboardingComplete(), isTrue);
  });
}

Future<void> _advanceToNextScene(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding-next-button')));
  await tester.pumpAndSettle();
}

Widget _buildHarness({
  required MushafPreparationService service,
}) {
  return ProviderScope(
    overrides: [
      mushafPreparationServiceProvider.overrideWithValue(service),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => CinematicOnboardingScreen(
              sceneVisualBuilder: (context, scene) {
                return Container(
                  key: Key('scene-visual-${scene.assetPath}'),
                  color: Colors.black,
                );
              },
            ),
          ),
          GoRoute(
            path: '/setup-mushaf',
            builder: (context, state) => const MushafSetupScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Library Route'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ImmediatePreparationService implements MushafPreparationService {
  @override
  Future<void> prepare({
    required void Function(double progress) onProgress,
  }) async {
    onProgress(0.4);
    await Future<void>.delayed(Duration.zero);
    onProgress(1.0);
  }
}

class _ControlledPreparationService implements MushafPreparationService {
  final Completer<void> _completer = Completer<void>();
  void Function(double progress)? _progress;

  @override
  Future<void> prepare({
    required void Function(double progress) onProgress,
  }) {
    _progress = onProgress;
    onProgress(0.2);
    return _completer.future;
  }

  void emitProgress(double progress) {
    _progress?.call(progress);
  }

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
