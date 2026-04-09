import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/analytics/providers/analytics_providers.dart';

class AnalyticsPeriodSelector extends ConsumerWidget {
  const AnalyticsPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(analyticsPeriodTypeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('analytics-period-selector'),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.10 : 0.14),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PeriodButton(
              key: const Key('analytics-period-week'),
              label: l10n.analyticsPeriodThisWeek,
              isSelected: selected == AnalyticsPeriodType.thisWeek,
              onTap: () {
                ref.read(analyticsPeriodTypeProvider.notifier).state =
                    AnalyticsPeriodType.thisWeek;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PeriodButton(
              key: const Key('analytics-period-month'),
              label: l10n.analyticsPeriodThisMonth,
              isSelected: selected == AnalyticsPeriodType.thisMonth,
              onTap: () {
                ref.read(analyticsPeriodTypeProvider.notifier).state =
                    AnalyticsPeriodType.thisMonth;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? AppColors.gold
                : (isDark ? AppColors.textDark : AppColors.textLight),
          ),
        ),
      ),
    );
  }
}
