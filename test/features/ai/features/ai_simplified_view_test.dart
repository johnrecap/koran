import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/features/simplify/ai_simplified_view.dart';
import 'package:quran_kareem/features/ai/features/simplify/tafsir_simplify_provider.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

void main() {
  testWidgets('shows shimmer while the simplification is loading',
      (tester) async {
    final completer = Completer<AiResponse>();
    const request = TafsirSimplifyRequest(
      surah: 2,
      ayah: 255,
      tafsirText: 'A sufficiently long tafsir text that should be simplified.',
    );

    await tester.pumpWidget(
      _buildHarness(
        request: request,
        overrides: [
          tafsirSimplifyProvider.overrideWith((ref, arg) => completer.future),
          aiQuotaRemainingProvider.overrideWith((ref) async => 12),
        ],
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('ai-loading-shimmer')), findsOneWidget);
    expect(find.text('Simplifying...'), findsOneWidget);
  });

  testWidgets('shows simplified text with disclaimer on success',
      (tester) async {
    const request = TafsirSimplifyRequest(
      surah: 2,
      ayah: 255,
      tafsirText:
          'This tafsir text is long enough to require a simplified AI summary.',
    );

    await tester.pumpWidget(
      _buildHarness(
        request: request,
        overrides: [
          tafsirSimplifyProvider.overrideWith(
            (ref, arg) async => AiResponse.fromRaw(
              'A concise explanation of the tafsir.',
              'test',
              120,
            ),
          ),
          aiQuotaRemainingProvider.overrideWith((ref) async => 14),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Simplified summary'), findsOneWidget);
    expect(find.text('A concise explanation of the tafsir.'), findsOneWidget);
    expect(find.byKey(const Key('ai-disclaimer-banner')), findsOneWidget);
    expect(find.byKey(const Key('ai-quota-indicator')), findsOneWidget);
  });

  testWidgets('shows retryable error state on timeout', (tester) async {
    var retryCount = 0;
    const request = TafsirSimplifyRequest(
      surah: 2,
      ayah: 255,
      tafsirText:
          'This tafsir text is long enough to require a simplified AI summary.',
    );

    await tester.pumpWidget(
      _buildHarness(
        request: request,
        overrides: [
          tafsirSimplifyProvider.overrideWith(
            (ref, arg) => Future<AiResponse>.error(
              AiTimeoutException(
                message: 'timeout',
                provider: 'test',
              ),
            ),
          ),
          aiQuotaRemainingProvider.overrideWith((ref) async => 9),
        ],
        onRetry: () {
          retryCount += 1;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-error-view')), findsOneWidget);
    expect(find.byKey(const Key('ai-error-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-error-retry')));
    await tester.pump();

    expect(retryCount, 1);
  });
}

Widget _buildHarness({
  required TafsirSimplifyRequest request,
  List<Override> overrides = const [],
  VoidCallback? onRetry,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 380,
            child: AiSimplifiedView(
              request: request,
              onRetry: onRetry,
            ),
          ),
        ),
      ),
    ),
  );
}
