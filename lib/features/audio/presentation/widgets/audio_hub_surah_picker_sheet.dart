import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';

Future<int?> showAudioHubSurahPickerSheet(
  BuildContext context, {
  required List<Surah> surahs,
  required int selectedSurahNumber,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => AudioHubSurahPickerSheet(
      surahs: surahs,
      selectedSurahNumber: selectedSurahNumber,
    ),
  );
}

class AudioHubSurahPickerSheet extends StatelessWidget {
  const AudioHubSurahPickerSheet({
    super.key,
    required this.surahs,
    required this.selectedSurahNumber,
  });

  final List<Surah> surahs;
  final int selectedSurahNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.audioHubSelectSurah,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: surahs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final surah = surahs[index];
                final isSelected = surah.number == selectedSurahNumber;

                return ListTile(
                  selected: isSelected,
                  leading: CircleAvatar(
                    child: Text(
                      surah.number.toString(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  title: Text(
                    surah.nameArabic,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Amiri',
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    surah.nameEnglish,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop(surah.number);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
