import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';

import 'package:quran_kareem/features/ai/widgets/ai_error_view.dart';

void main() {
  testWidgets('offline error shows offline message without retry button',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: AiErrorView(
          exception: AiOfflineException(
            message: 'offline',
            provider: 'test',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This feature requires an internet connection.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ai-error-retry')), findsNothing);
  });

  testWidgets('timeout error shows retry button and triggers callback',
      (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        child: AiErrorView(
          exception: AiTimeoutException(
            message: 'timeout',
            provider: 'test',
          ),
          onRetry: () {
            retryCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('We could not get a response in time.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ai-error-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-error-retry')));
    await tester.pump();

    expect(retryCount, 1);
  });

  testWidgets('quota exhausted error shows quota message without retry',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: AiErrorView(
          exception: AiQuotaExceededException(
            message: 'quota',
            provider: 'test',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('You have reached today\'s free AI limit. Try again tomorrow.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ai-error-retry')), findsNothing);
    expect(find.byKey(const Key('ai-error-upgrade')), findsOneWidget);
  });

  testWidgets('provider network error shows offline messaging',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: AiErrorView(
          exception: AiProviderException(
            message: 'request failed',
            provider: 'test',
            originalError: const SocketException('Failed host lookup'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This feature requires an internet connection.'),
      findsOneWidget,
    );
    expect(
      find.text('A technical error occurred. Please try again.'),
      findsNothing,
    );
  });

  testWidgets('safety error shows safety message without retry button',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: AiErrorView(
          exception: AiSafetyException(
            message: 'unsafe',
            provider: 'test',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('We could not process this request safely.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ai-error-retry')), findsNothing);
    expect(find.byKey(const Key('ai-error-upgrade')), findsNothing);
  });
}

Widget _buildHarness({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: child,
          ),
        ),
      ),
    ),
  );
}
