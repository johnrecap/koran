import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/library/presentation/widgets/library_topic_reference_tile.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

class LibraryTopicDetailsScreen extends ConsumerWidget {
  const LibraryTopicDetailsScreen({
    super.key,
    required this.topic,
    required this.onOpenAyah,
  });

  final LibraryTopic topic;
  final ValueChanged<LibraryTopicReferenceResult> onOpenAyah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageCode = Localizations.localeOf(context).languageCode;
    final title = topic.localizedTitle(languageCode);
    final description = topic.localizedDescription(languageCode);
    final referencesAsync = ref.watch(
      libraryTopicReferenceResultsProvider(topic.id),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.textMuted,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: referencesAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return _TopicStateMessage(
                    icon: Icons.menu_book_outlined,
                    title: l10n.libraryTopicsDetailsEmpty,
                    isDark: isDark,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return LibraryTopicReferenceTile(
                      result: result,
                      onTap: () => onOpenAyah(result),
                    );
                  },
                );
              },
              loading: () => _TopicStateMessage(
                icon: Icons.hourglass_empty_rounded,
                title: l10n.libraryTopicsDetailsLoading,
                isDark: isDark,
                loading: true,
              ),
              error: (error, stackTrace) => _TopicStateMessage(
                icon: Icons.error_outline_rounded,
                title: l10n.libraryTopicsDetailsLoadError,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicStateMessage extends StatelessWidget {
  const _TopicStateMessage({
    required this.icon,
    required this.title,
    required this.isDark,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              )
            else
              Icon(
                icon,
                size: 56,
                color: AppColors.gold.withValues(alpha: 0.32),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 17,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
