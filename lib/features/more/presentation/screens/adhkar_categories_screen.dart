import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/providers/adhkar_providers.dart';
import 'package:quran_kareem/features/more/presentation/widgets/adhkar_category_card.dart';
import 'package:quran_kareem/features/more/presentation/widgets/adhkar_counter_card.dart';

class AdhkarCategoriesScreen extends ConsumerWidget {
  const AdhkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionsAsync = ref.watch(adhkarCategorySectionsProvider);
    final counterState = ref.watch(adhkarCounterProvider);
    final counterProgress = AdhkarPolicies.counterProgress(counterState);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        title: Text(
          l10n.homeToolsAzkar,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: sectionsAsync.when(
        data: (sections) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              AdhkarCounterCard(
                count: counterState.count,
                target: counterState.target,
                title: l10n.adhkarCounterTitle,
                incrementTooltip: l10n.adhkarCounterIncrement,
                resetLabel: l10n.adhkarCounterReset,
                targetLabel: l10n.adhkarCounterTargetLabel,
                freeTargetLabel: l10n.adhkarCounterFreeTarget,
                progress: counterProgress,
                onIncrement: () {
                  ref.read(adhkarCounterProvider.notifier).increment();
                },
                onReset: () {
                  ref.read(adhkarCounterProvider.notifier).reset();
                },
                onTargetSelected: (value) {
                  ref.read(adhkarCounterProvider.notifier).setTarget(value);
                },
              ),
              for (final section in sections) ...[
                Text(
                  _groupTitle(context, section.id),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                for (final category in section.categories)
                  AdhkarCategoryCard(
                    categoryId: category.id,
                    title: _categoryTitle(context, category.id),
                    subtitle: category.sourceNote ?? category.sourceLabel,
                    entryCountLabel:
                        '${category.entries.length} ${l10n.adhkarItemsLabel}',
                    onTap: () => context.push('/more/adhkar/${category.id}'),
                  ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
        loading: () => _AdhkarMessageState(
          message: l10n.adhkarLoading,
          child: const CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
        ),
        error: (error, stackTrace) => _AdhkarMessageState(
          message: l10n.adhkarError,
          child: ElevatedButton(
            onPressed: () {
              ref.invalidate(adhkarCatalogProvider);
              ref.invalidate(adhkarCategorySectionsProvider);
            },
            child: Text(l10n.homeToolsRetry),
          ),
        ),
      ),
    );
  }

  String _groupTitle(BuildContext context, String groupId) {
    final l10n = context.l10n;
    return switch (groupId) {
      'dailyCore' => l10n.adhkarGroupDailyCore,
      'heartWork' => l10n.adhkarGroupHeartWork,
      'lifeNeeds' => l10n.adhkarGroupLifeNeeds,
      'sourceLed' => l10n.adhkarGroupSourceLed,
      _ => l10n.homeToolsAzkar,
    };
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
}

class _AdhkarMessageState extends StatelessWidget {
  const _AdhkarMessageState({
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

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
            child,
            const SizedBox(height: 14),
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
