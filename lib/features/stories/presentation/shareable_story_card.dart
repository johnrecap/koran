import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';
import 'package:share_plus/share_plus.dart';

typedef StoryCardTempDirectoryProvider = Future<Directory> Function();
typedef StoryCardShareInvoker = Future<void> Function(ShareParams params);
typedef StoryCardBoundaryCapture = Future<Uint8List> Function(
  GlobalKey repaintBoundaryKey,
  double pixelRatio,
);
typedef StoryCardErrorLogger = void Function(
  String context,
  Object error, [
  StackTrace? stackTrace,
]);

class StoryCardImageExporter {
  StoryCardImageExporter({
    this.pixelRatio = 2.0,
    StoryCardTempDirectoryProvider? tempDirectoryProvider,
    StoryCardShareInvoker? shareInvoker,
    StoryCardBoundaryCapture? boundaryCapture,
    StoryCardErrorLogger? logError,
  })  : _tempDirectoryProvider = tempDirectoryProvider ?? getTemporaryDirectory,
        _shareInvoker = shareInvoker ?? _defaultShareInvoker,
        _boundaryCapture = boundaryCapture ?? _defaultBoundaryCapture,
        _logError = logError ?? AppLogger.error;

  final double pixelRatio;
  final StoryCardTempDirectoryProvider _tempDirectoryProvider;
  final StoryCardShareInvoker _shareInvoker;
  final StoryCardBoundaryCapture _boundaryCapture;
  final StoryCardErrorLogger _logError;

  Future<Uint8List?> captureCard(GlobalKey repaintBoundaryKey) async {
    try {
      return await _boundaryCapture(repaintBoundaryKey, pixelRatio);
    } catch (error, stackTrace) {
      _logError('StoryCardImageExporter.captureCard', error, stackTrace);
      return null;
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
      _logError('StoryCardImageExporter.shareImage', error, stackTrace);
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

  static Future<Uint8List> _defaultBoundaryCapture(
    GlobalKey repaintBoundaryKey,
    double pixelRatio,
  ) async {
    final context = repaintBoundaryKey.currentContext;
    if (context == null) {
      throw StateError('Story-card boundary is unavailable.');
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError(
        'Story-card boundary did not resolve to a repaint boundary.',
      );
    }

    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Story-card image encoding returned no bytes.');
      }

      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  static String _normalizeFileName(String fileName) {
    final trimmed = fileName.trim();
    final baseName = trimmed.isEmpty ? 'story-card' : trimmed;
    final sanitized = baseName
        .replaceAll(RegExp(r'[<>:"/\\|?*]+'), '-')
        .replaceAll(RegExp(r'\s+'), '-');

    if (sanitized.toLowerCase().endsWith('.png')) {
      return sanitized;
    }

    return '$sanitized.png';
  }
}

class ShareableStoryCard extends StatelessWidget {
  const ShareableStoryCard({
    super.key,
    required this.story,
    required this.chapter,
  });

  final QuranStory story;
  final StoryChapter chapter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final title = isEnglish && story.titleEn.trim().isNotEmpty
        ? story.titleEn
        : story.titleAr;
    final chapterTitle = isEnglish && chapter.titleEn.trim().isNotEmpty
        ? chapter.titleEn
        : chapter.titleAr;
    final lesson = isEnglish && chapter.lessonEn.trim().isNotEmpty
        ? chapter.lessonEn
        : chapter.lessonAr;

    return Container(
      key: const Key('shareable-story-card-surface'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.30 : 0.18),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            bottom: 8,
            end: 8,
            child: Opacity(
              opacity: isDark ? 0.08 : 0.05,
              child: Text(
                context.l10n.quranStories,
                key: const Key('shareable-story-card-watermark'),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  key: const Key('shareable-story-card-branding'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        AppColors.gold.withValues(alpha: isDark ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        size: 18,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.appTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.gold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: isDark ? 0.16 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chapterTitle,
                  key: const Key('shareable-story-card-chapter-title'),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDark : AppColors.gold,
                  ),
                ),
              ),
              if (chapter.verses.isNotEmpty) ...[
                const SizedBox(height: 18),
                for (var index = 0;
                    index < chapter.verses.length;
                    index += 1) ...[
                  _ShareableStoryVersePanel(
                    verseText: chapter.verses[index].textAr,
                    contextText: chapter.verses[index].contextAr,
                  ),
                  if (index < chapter.verses.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
              if (lesson.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  key: const Key('shareable-story-card-lesson'),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success
                          .withValues(alpha: isDark ? 0.32 : 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.storiesLesson,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lesson,
                        style: TextStyle(
                          fontFamily: isEnglish ? null : 'Amiri',
                          fontSize: isEnglish ? 15 : 18,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color:
                              isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareableStoryVersePanel extends StatelessWidget {
  const _ShareableStoryVersePanel({
    required this.verseText,
    required this.contextText,
  });

  final String verseText;
  final String contextText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              verseText,
              key: const Key('shareable-story-card-verse'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.7,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
          if (contextText.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              contextText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
