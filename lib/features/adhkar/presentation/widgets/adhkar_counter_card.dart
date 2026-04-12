import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

class AdhkarCounterCard extends StatelessWidget {
  const AdhkarCounterCard({
    super.key,
    required this.count,
    required this.target,
    required this.title,
    required this.incrementTooltip,
    required this.resetLabel,
    required this.targetLabel,
    required this.freeTargetLabel,
    required this.onIncrement,
    required this.onReset,
    required this.onTargetSelected,
    this.progress,
    this.targets = const <int>[33, 100],
  });

  final int count;
  final int? target;
  final String title;
  final String incrementTooltip;
  final String resetLabel;
  final String targetLabel;
  final String freeTargetLabel;
  final VoidCallback onIncrement;
  final VoidCallback onReset;
  final ValueChanged<int?> onTargetSelected;
  final double? progress;
  final List<int> targets;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor = isDark ? AppColors.textDark : AppColors.textMuted;

    return Container(
      key: const Key('adhkar-counter-card'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      target == null ? freeTargetLabel : '$targetLabel $target',
                      style: TextStyle(
                        fontSize: 13,
                        color: captionColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                key: const Key('adhkar-counter-increment'),
                onPressed: onIncrement,
                tooltip: incrementTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: AppColors.gold,
                backgroundColor: AppColors.camel.withValues(alpha: 0.18),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final value in targets)
                ChoiceChip(
                  label: Text(value.toString()),
                  selected: target == value,
                  onSelected: (_) => onTargetSelected(value),
                ),
              ChoiceChip(
                label: Text(freeTargetLabel),
                selected: target == null,
                onSelected: (_) => onTargetSelected(null),
              ),
              TextButton(
                key: const Key('adhkar-counter-reset'),
                onPressed: onReset,
                child: Text(resetLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
