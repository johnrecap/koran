import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';

Future<String?> showAudioHubReciterPickerSheet(
  BuildContext context, {
  required List<AudioHubReciterOption> reciters,
  required String selectedReciterId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => AudioHubReciterPickerSheet(
      reciters: reciters,
      selectedReciterId: selectedReciterId,
    ),
  );
}

class AudioHubReciterPickerSheet extends StatelessWidget {
  const AudioHubReciterPickerSheet({
    super.key,
    required this.reciters,
    required this.selectedReciterId,
  });

  final List<AudioHubReciterOption> reciters;
  final String selectedReciterId;

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
                    l10n.audioHubSelectReciter,
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
              itemCount: reciters.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final reciter = reciters[index];
                final isSelected = reciter.id == selectedReciterId;

                return ListTile(
                  selected: isSelected,
                  title: Text(
                    reciter.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Amiri',
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop(reciter.id);
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
