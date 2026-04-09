import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_template.dart';
import 'package:share_plus/share_plus.dart';

class AyahShareCardExportResult {
  const AyahShareCardExportResult({
    required this.filePath,
    required this.fileName,
  });

  final String filePath;
  final String fileName;

  XFile toXFile() {
    return XFile(
      filePath,
      name: fileName,
      mimeType: 'image/png',
    );
  }
}

abstract class AyahShareCardExportService {
  Future<AyahShareCardExportResult> export({
    required GlobalKey repaintBoundaryKey,
    required AyahShareCardTemplate template,
    required AyahShareCardPayload payload,
  });
}

abstract class AyahShareCardShareService {
  Future<void> share(AyahShareCardExportResult result);
}

class RepaintBoundaryAyahShareCardExportService
    implements AyahShareCardExportService {
  const RepaintBoundaryAyahShareCardExportService({
    this.pixelRatio = 3,
  });

  final double pixelRatio;

  @override
  Future<AyahShareCardExportResult> export({
    required GlobalKey repaintBoundaryKey,
    required AyahShareCardTemplate template,
    required AyahShareCardPayload payload,
  }) async {
    final context = repaintBoundaryKey.currentContext;
    if (context == null) {
      throw StateError('Share-card boundary is unavailable.');
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError(
          'Share-card boundary did not resolve to a repaint boundary.');
    }

    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Share-card image encoding returned no bytes.');
      }

      final directory = await getTemporaryDirectory();
      const fileName = 'ayah-share-card.png';
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      return AyahShareCardExportResult(
        filePath: file.path,
        fileName: fileName,
      );
    } finally {
      image.dispose();
    }
  }
}

class SharePlusAyahShareCardShareService implements AyahShareCardShareService {
  const SharePlusAyahShareCardShareService();

  @override
  Future<void> share(AyahShareCardExportResult result) {
    return SharePlus.instance.share(
      ShareParams(
        files: [result.toXFile()],
      ),
    );
  }
}
