import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/quizzes/utils/quiz_card_image_exporter.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captureCard returns valid PNG bytes from a repaint boundary',
      (tester) async {
    final exportKey = GlobalKey();
    GlobalKey? receivedKey;
    double? receivedPixelRatio;
    final exporter = QuizCardImageExporter(
      boundaryCapture: (repaintBoundaryKey, pixelRatio) async {
        receivedKey = repaintBoundaryKey;
        receivedPixelRatio = pixelRatio;
        return Uint8List.fromList(
          <int>[137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3, 4],
        );
      },
      logError: _ignoreLogError,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: exportKey,
            child: Container(
              width: 240,
              height: 120,
              color: Colors.white,
              alignment: Alignment.center,
              child: const Text('Quiz export'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final bytes = await exporter.captureCard(exportKey);

    expect(bytes, isNotNull);
    expect(bytes, isNotEmpty);
    expect(
      bytes!.sublist(0, 8),
      equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    );
    expect(receivedKey, same(exportKey));
    expect(receivedPixelRatio, 3.0);
  });

  test('saveToGallery writes to temp dir and calls save API', () async {
    final tempDir = await Directory.systemTemp.createTemp('quiz_card_save');
    addTearDown(() => tempDir.delete(recursive: true));

    Uint8List? savedBytes;
    String? savedFileName;
    final exporter = QuizCardImageExporter(
      tempDirectoryProvider: () async => tempDir,
      gallerySaver: (bytes, fileName) async {
        savedBytes = bytes;
        savedFileName = fileName;
        return QuizCardImageSaveOutcome.success;
      },
      logError: _ignoreLogError,
    );

    final bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);

    final outcome = await exporter.saveToGallery(bytes, 'review card');

    expect(outcome, QuizCardImageSaveOutcome.success);
    final file = File('${tempDir.path}${Platform.pathSeparator}review-card.png');
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), equals(bytes));
    expect(savedBytes, equals(bytes));
    expect(savedFileName, 'review-card.png');
  });

  test('shareImage writes to temp dir and calls share_plus', () async {
    final tempDir = await Directory.systemTemp.createTemp('quiz_card_share');
    addTearDown(() => tempDir.delete(recursive: true));

    ShareParams? receivedParams;
    final exporter = QuizCardImageExporter(
      tempDirectoryProvider: () async => tempDir,
      shareInvoker: (params) async {
        receivedParams = params;
      },
      logError: _ignoreLogError,
    );

    final shared = await exporter.shareImage(
      Uint8List.fromList(<int>[4, 3, 2, 1]),
      'quiz card',
    );

    expect(shared, isTrue);
    expect(receivedParams, isNotNull);
    expect(receivedParams!.files, isNotNull);
    expect(receivedParams!.files, hasLength(1));
    expect(receivedParams!.files!.single.name, 'quiz-card.png');
    expect(
      await receivedParams!.files!.single.readAsBytes(),
      equals(Uint8List.fromList(<int>[4, 3, 2, 1])),
    );
  });

  test('captureCard logs failures and returns null when boundary is unavailable',
      () async {
    final loggedErrors = <_LoggedError>[];
    final exporter = QuizCardImageExporter(
      logError: (context, error, [stackTrace]) {
        loggedErrors.add(
          _LoggedError(
            context: context,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      },
    );

    final bytes = await exporter.captureCard(GlobalKey());

    expect(bytes, isNull);
    expect(loggedErrors, hasLength(1));
    expect(
      loggedErrors.single.context,
      'QuizCardImageExporter.captureCard',
    );
    expect(loggedErrors.single.error, isA<StateError>());
  });
}

void _ignoreLogError(String context, Object error, [StackTrace? stackTrace]) {}

class _LoggedError {
  const _LoggedError({
    required this.context,
    required this.error,
    required this.stackTrace,
  });

  final String context;
  final Object error;
  final StackTrace? stackTrace;
}
