import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:quran_kareem/features/ai/widgets/ai_quota_indicator.dart';

void main() {
  testWidgets('displays the remaining quota count', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiQuotaRemainingProvider.overrideWith((ref) async => 15),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('15/20 remaining today'), findsOneWidget);
  });

  testWidgets('uses the red state color when remaining quota is under five',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiQuotaRemainingProvider.overrideWith((ref) async => 3),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(
      find.byKey(const Key('ai-quota-indicator')),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, AppColors.error.withValues(alpha: 0.14));
  });
}

Widget _buildHarness({
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Scaffold(
        body: Center(
          child: AiQuotaIndicator(),
        ),
      ),
    ),
  );
}
