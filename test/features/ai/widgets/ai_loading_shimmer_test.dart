import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/ai/widgets/ai_loading_shimmer.dart';

void main() {
  testWidgets('shimmer renders label and skeleton lines', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AiLoadingShimmer(
            label: 'Loading summary...',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Loading summary...'), findsOneWidget);
    expect(find.byKey(const Key('ai-loading-shimmer-line-1')), findsOneWidget);
    expect(find.byKey(const Key('ai-loading-shimmer-line-2')), findsOneWidget);
    expect(find.byKey(const Key('ai-loading-shimmer-line-3')), findsOneWidget);
  });
}
