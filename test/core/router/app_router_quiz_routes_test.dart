import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers the quiz routes in the app router source', () {
    final source = File(
      'lib/core/router/app_router.dart',
    ).readAsStringSync();

    expect(source, contains("path: '/memorization/quiz'"));
    expect(source, contains("path: '/memorization/quiz/session'"));
    expect(source, contains("path: '/memorization/quiz/result'"));
    expect(source, contains("path: '/memorization/quiz/history'"));
    expect(source, contains('QuizHubScreen('));
    expect(source, contains('QuizSessionScreen('));
    expect(source, contains('QuizResultScreen('));
    expect(source, contains('QuizHistoryScreen('));
  });
}
