import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

class AsbaabSectionView extends StatelessWidget {
  const AsbaabSectionView({
    super.key,
    required this.entries,
  });

  final List<AsbaabEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.text,
                style: textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Amiri',
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${context.l10n.insightAsbaabSource}: ${entry.source}',
                textAlign: TextAlign.start,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
