import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:share_plus/share_plus.dart';

enum QuizCardImageSaveOutcome {
  success,
  permissionDenied,
  failure,
}

typedef QuizCardTempDirectoryProvider = Future<Directory> Function();
typedef QuizCardShareInvoker = Future<void> Function(ShareParams params);
typedef QuizCardGallerySaver = Future<QuizCardImageSaveOutcome> Function(
  Uint8List pngBytes,
  String fileName,
);
typedef QuizCardBoundaryCapture = Future<Uint8List> Function(
  GlobalKey repaintBoundaryKey,
  double pixelRatio,
);
typedef QuizCardErrorLogger = void Function(
  String context,
  Object error, [
  StackTrace? stackTrace,
]);

class QuizCardImageExporter {
  QuizCardImageExporter({
    this.pixelRatio = 3.0,
    QuizCardTempDirectoryProvider? tempDirectoryProvider,
    QuizCardShareInvoker? shareInvoker,
    QuizCardGallerySaver? gallerySaver,
    QuizCardBoundaryCapture? boundaryCapture,
    QuizCardErrorLogger? logError,
  })  : _tempDirectoryProvider = tempDirectoryProvider ?? getTemporaryDirectory,
        _shareInvoker = shareInvoker ?? _defaultShareInvoker,
        _gallerySaver = gallerySaver ?? _defaultGallerySaver,
        _boundaryCapture = boundaryCapture ?? _defaultBoundaryCapture,
        _logError = logError ?? AppLogger.error;

  static const MethodChannel _channel = MethodChannel(
    'quran_kareem/quiz_card_image_exporter',
  );

  final double pixelRatio;
  final QuizCardTempDirectoryProvider _tempDirectoryProvider;
  final QuizCardShareInvoker _shareInvoker;
  final QuizCardGallerySaver _gallerySaver;
  final QuizCardBoundaryCapture _boundaryCapture;
  final QuizCardErrorLogger _logError;

  Future<Uint8List?> captureCard(GlobalKey repaintBoundaryKey) async {
    try {
      return await _boundaryCapture(repaintBoundaryKey, pixelRatio);
    } catch (error, stackTrace) {
      _logError('QuizCardImageExporter.captureCard', error, stackTrace);
      return null;
    }
  }

  Future<QuizCardImageSaveOutcome> saveToGallery(
    Uint8List pngBytes,
    String fileName,
  ) async {
    final normalizedFileName = _normalizeFileName(fileName);

    try {
      await _writeTempFile(pngBytes, normalizedFileName);
      return _gallerySaver(pngBytes, normalizedFileName);
    } catch (error, stackTrace) {
      _logError('QuizCardImageExporter.saveToGallery', error, stackTrace);
      return QuizCardImageSaveOutcome.failure;
    }
  }

  Future<bool> shareImage(Uint8List pngBytes, String fileName) async {
    final normalizedFileName = _normalizeFileName(fileName);

    try {
      final file = await _writeTempFile(pngBytes, normalizedFileName);
      await _shareInvoker(
        ShareParams(
          files: [
            XFile(
              file.path,
              name: normalizedFileName,
              mimeType: 'image/png',
            ),
          ],
        ),
      );
      return true;
    } catch (error, stackTrace) {
      _logError('QuizCardImageExporter.shareImage', error, stackTrace);
      return false;
    }
  }

  Future<File> _writeTempFile(Uint8List pngBytes, String fileName) async {
    final directory = await _tempDirectoryProvider();
    final file = File(p.join(directory.path, fileName));
    await file.writeAsBytes(pngBytes, flush: true);
    return file;
  }

  static Future<void> _defaultShareInvoker(ShareParams params) async {
    await SharePlus.instance.share(params);
  }

  static Future<QuizCardImageSaveOutcome> _defaultGallerySaver(
    Uint8List pngBytes,
    String fileName,
  ) async {
    try {
      await _channel.invokeMethod<void>(
        'saveImageToGallery',
        <String, Object?>{
          'bytes': pngBytes,
          'fileName': fileName,
        },
      );
      return QuizCardImageSaveOutcome.success;
    } on PlatformException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        return QuizCardImageSaveOutcome.permissionDenied;
      }

      AppLogger.error(
        'QuizCardImageExporter._defaultGallerySaver',
        error,
        stackTrace,
      );
      return QuizCardImageSaveOutcome.failure;
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuizCardImageExporter._defaultGallerySaver',
        error,
        stackTrace,
      );
      return QuizCardImageSaveOutcome.failure;
    }
  }

  static Future<Uint8List> _defaultBoundaryCapture(
    GlobalKey repaintBoundaryKey,
    double pixelRatio,
  ) async {
    final context = repaintBoundaryKey.currentContext;
    if (context == null) {
      throw StateError('Quiz-card boundary is unavailable.');
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError(
        'Quiz-card boundary did not resolve to a repaint boundary.',
      );
    }

    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Quiz-card image encoding returned no bytes.');
      }

      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  static String _normalizeFileName(String fileName) {
    final trimmed = fileName.trim();
    final baseName = trimmed.isEmpty ? 'quiz-card' : trimmed;
    final sanitized = baseName
        .replaceAll(RegExp(r'[<>:"/\\|?*]+'), '-')
        .replaceAll(RegExp(r'\s+'), '-');

    if (sanitized.toLowerCase().endsWith('.png')) {
      return sanitized;
    }

    return '$sanitized.png';
  }
}
