import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/adhkar/presentation/widgets/adhkar_entry_card.dart';
import 'package:quran_kareem/features/adhkar/providers/adhkar_providers.dart';

class AdhkarCategoryDetailScreen extends ConsumerWidget {
  const AdhkarCategoryDetailScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryAsync = ref.watch(adhkarCategoryProvider(categoryId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        title: Text(
          _categoryTitle(context, categoryId),
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: categoryAsync.when(
        data: (category) {
          if (category == null) {
            return _DetailMessageState(
              message: context.l10n.adhkarCategoryNotFound,
            );
          }

          if (category.entries.isEmpty) {
            return _DetailMessageState(
              message: context.l10n.adhkarEmptyCategory,
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDarkNav : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.l10n.adhkarTrustedSourceLabel}: ${category.sourceLabel}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    if (category.sourceNote != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        category.sourceNote!,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDark ? AppColors.textDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              for (final entry in category.entries)
                AdhkarEntryCard(
                  entryId: entry.id,
                  arabicText: entry.arabicText,
                  repetitionLabel: entry.repetitionCount == null
                      ? null
                      : '${context.l10n.adhkarRepetitionLabel}: ${entry.repetitionCount}',
                  metadataItems: _buildMetadataItems(context, entry),
                ),
            ],
          );
        },
        loading: () => _DetailMessageState(
          message: context.l10n.adhkarLoading,
          child: const CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
        ),
        error: (error, stackTrace) => _DetailMessageState(
          message: context.l10n.adhkarError,
          child: ElevatedButton(
            onPressed: () {
              ref.invalidate(adhkarCatalogProvider);
              ref.invalidate(adhkarCategoryProvider(categoryId));
            },
            child: Text(context.l10n.homeToolsRetry),
          ),
        ),
      ),
    );
  }

  String _categoryTitle(BuildContext context, String categoryId) {
    final l10n = context.l10n;
    return switch (categoryId) {
      'morning' => l10n.adhkarCategoryMorning,
      'evening' => l10n.adhkarCategoryEvening,
      'afterPrayer' => l10n.adhkarCategoryAfterPrayer,
      'sleep' => l10n.adhkarCategorySleep,
      'waking' => l10n.adhkarCategoryWaking,
      'istighfar' => l10n.adhkarCategoryIstighfar,
      'rizq' => l10n.adhkarCategoryRizq,
      'distress' => l10n.adhkarCategoryDistress,
      'travel' => l10n.adhkarCategoryTravel,
      'quranDuas' => l10n.adhkarCategoryQuranDuas,
      'sunnahDuas' => l10n.adhkarCategorySunnahDuas,
      _ => l10n.homeToolsAzkar,
    };
  }

  List<AdhkarEntryMetadataItem> _buildMetadataItems(
    BuildContext context,
    AdhkarEntry entry,
  ) {
    final l10n = context.l10n;
    final items = <AdhkarEntryMetadataItem>[];

    void addItem(String label, String? value) {
      if (value == null || value.trim().isEmpty) {
        return;
      }
      items.add(
        AdhkarEntryMetadataItem(
          label: label,
          value: value,
        ),
      );
    }

    addItem(l10n.adhkarVirtueLabel, entry.virtue);
    addItem(l10n.adhkarTimingLabel, entry.timingNote);
    addItem(l10n.adhkarAuthenticityLabel, entry.authenticityNote);
    addItem(l10n.adhkarSourceDetailLabel, entry.sourceDetail);
    addItem(l10n.adhkarSourceLabel, entry.reference);
    addItem(l10n.adhkarNoteLabel, entry.note);

    return items;
  }
}

class _DetailMessageState extends StatelessWidget {
  const _DetailMessageState({
    required this.message,
    this.child,
  });

  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkNav : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child != null) ...[
              child!,
              const SizedBox(height: 14),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
