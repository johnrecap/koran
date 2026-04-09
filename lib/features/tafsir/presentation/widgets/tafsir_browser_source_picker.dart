import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_source_option.dart';

List<DropdownMenuItem<String>> buildTafsirBrowserSourceItems(
  List<TafsirBrowserSourceOption> options,
) {
  return options
      .map(
        (option) => DropdownMenuItem<String>(
          value: option.id,
          enabled: option.isDownloaded,
          child: Text(option.title),
        ),
      )
      .toList(growable: false);
}

class TafsirBrowserSourcePicker extends StatelessWidget {
  const TafsirBrowserSourcePicker({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final List<TafsirBrowserSourceOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    final selected = options.firstWhere(
      (option) => option.isSelected,
      orElse: () => options.first,
    );

    return DropdownButtonFormField<String>(
      key: ValueKey(selected.id),
      initialValue: selected.id,
      decoration: InputDecoration(
        labelText: context.l10n.tafsirBrowserSourceLabel,
        border: const OutlineInputBorder(),
      ),
      items: buildTafsirBrowserSourceItems(options),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
      },
    );
  }
}
