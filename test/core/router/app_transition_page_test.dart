import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/router/app_transition_page.dart';

void main() {
  test('creates a custom transition page for sub-routes', () {
    const page = AppTransitionPage<void>(
      key: ValueKey<String>('settings-page'),
      child: SizedBox(),
    );

    expect(page, isA<CustomTransitionPage<void>>());
    expect(page.key, const ValueKey<String>('settings-page'));
  });
}
