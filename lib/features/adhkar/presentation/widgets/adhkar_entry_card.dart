import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

class AdhkarEntryCard extends StatelessWidget {
  const AdhkarEntryCard({
    super.key,
    required this.entryId,
    required this.arabicText,
    this.repetitionLabel,
    this.metadataItems = const <AdhkarEntryMetadataItem>[],
  });

  final String entryId;
  final String arabicText;
  final String? repetitionLabel;
  final List<AdhkarEntryMetadataItem> metadataItems;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor = isDark ? AppColors.textDark : AppColors.textMuted;

    return Container(
      key: Key('adhkar-entry-card-$entryId'),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (repetitionLabel != null) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.camel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  repetitionLabel!,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            arabicText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              height: 1.9,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          if (metadataItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (var index = 0; index < metadataItems.length; index += 1) ...[
              if (index > 0) const SizedBox(height: 12),
              Text(
                metadataItems[index].label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: captionColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metadataItems[index].value,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: captionColor,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class AdhkarEntryMetadataItem {
  const AdhkarEntryMetadataItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}
