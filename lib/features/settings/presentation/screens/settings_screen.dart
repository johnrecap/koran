import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/notifications/presentation/widgets/notification_time_picker_tile.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_schedule_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';
import 'package:quran_kareem/features/settings/presentation/widgets/settings_preview_card.dart';
import 'package:quran_kareem/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(appSettingsControllerProvider);
    final controller = ref.read(appSettingsControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        children: [
          SettingsPreviewCard(settings: settings),
          const SizedBox(height: 18),
          SettingsSectionCard(
            title: l10n.settingsSectionAppearance,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: l10n.settingsThemeLabel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _OptionChip(
                      chipKey: const Key('settings-theme-system-option'),
                      label: l10n.settingsThemeSystem,
                      selected: settings.themeMode == ThemeMode.system,
                      onSelected: () => controller.setThemeMode(
                        ThemeMode.system,
                      ),
                    ),
                    _OptionChip(
                      chipKey: const Key('settings-theme-light-option'),
                      label: l10n.settingsThemeLight,
                      selected: settings.themeMode == ThemeMode.light,
                      onSelected: () => controller.setThemeMode(
                        ThemeMode.light,
                      ),
                    ),
                    _OptionChip(
                      chipKey: const Key('settings-theme-dark-option'),
                      label: l10n.settingsThemeDark,
                      selected: settings.themeMode == ThemeMode.dark,
                      onSelected: () => controller.setThemeMode(
                        ThemeMode.dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionLabel(label: l10n.settingsLanguageLabel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _OptionChip(
                      chipKey: const Key('settings-language-ar-option'),
                      label: l10n.settingsLanguageArabic,
                      selected: settings.locale.languageCode == 'ar',
                      onSelected: () =>
                          controller.setLocale(const Locale('ar')),
                    ),
                    _OptionChip(
                      chipKey: const Key('settings-language-en-option'),
                      label: l10n.settingsLanguageEnglish,
                      selected: settings.locale.languageCode == 'en',
                      onSelected: () =>
                          controller.setLocale(const Locale('en')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SettingsSectionCard(
            title: l10n.settingsSectionReading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: l10n.settingsFontSizeLabel),
                Slider(
                  key: const Key('settings-font-size-slider'),
                  value: settings.arabicFontSize,
                  min: SettingsArabicFontSizePolicy.minimum,
                  max: SettingsArabicFontSizePolicy.maximum,
                  divisions: SettingsArabicFontSizePolicy.divisions,
                  label: settings.arabicFontSize.toStringAsFixed(0),
                  onChanged: controller.setArabicFontSize,
                ),
                Text(
                  l10n.settingsFontSizeHelp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.55,
                        color: isDark ? Colors.white70 : AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 18),
                _SectionLabel(label: l10n.settingsReaderModeLabel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _OptionChip(
                      chipKey: const Key('settings-reader-mode-scroll-option'),
                      label: l10n.readerModeScroll,
                      selected: settings.defaultReaderMode == ReaderMode.scroll,
                      onSelected: () => controller.setDefaultReaderMode(
                        ReaderMode.scroll,
                      ),
                    ),
                    _OptionChip(
                      chipKey: const Key('settings-reader-mode-page-option'),
                      label: l10n.readerModePage,
                      selected: settings.defaultReaderMode == ReaderMode.page,
                      onSelected: () => controller.setDefaultReaderMode(
                        ReaderMode.page,
                      ),
                    ),
                    _OptionChip(
                      chipKey:
                          const Key('settings-reader-mode-translation-option'),
                      label: l10n.readerModeTranslation,
                      selected:
                          settings.defaultReaderMode == ReaderMode.translation,
                      onSelected: () => controller.setDefaultReaderMode(
                        ReaderMode.translation,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsTajweedLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.settingsTajweedHelp,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      height: 1.5,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      key: const Key('settings-tajweed-switch'),
                      value: settings.tajweedEnabled,
                      onChanged: controller.setTajweedEnabled,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SettingsSectionCard(
            key: const Key('settings-night-reader-section'),
            title: l10n.settingsSectionNightReader,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsNightReaderAutoEnableLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.settingsNightReaderAutoEnableHelp,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      height: 1.5,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      key: const Key('settings-night-reader-auto-enable-switch'),
                      value: settings.nightReaderSettings.autoEnable,
                      onChanged: controller.setNightReaderAutoEnable,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _buildNightReaderSummary(
                    context,
                    l10n,
                    settings.nightReaderSettings,
                  ),
                  key: const Key('settings-night-reader-summary'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: isDark ? Colors.white70 : AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 18),
                NotificationTimePickerTile(
                  key: const Key('settings-night-reader-start-tile'),
                  label: l10n.settingsNightReaderStartLabel,
                  time: _timeOfDayFromMinutes(
                    settings.nightReaderSettings.startMinutes,
                  ),
                  onPressed: () => _selectNightReaderTime(
                    context: context,
                    l10n: l10n,
                    controller: controller,
                    settings: settings.nightReaderSettings,
                    isStart: true,
                  ),
                ),
                NotificationTimePickerTile(
                  key: const Key('settings-night-reader-end-tile'),
                  label: l10n.settingsNightReaderEndLabel,
                  time: _timeOfDayFromMinutes(
                    settings.nightReaderSettings.endMinutes,
                  ),
                  onPressed: () => _selectNightReaderTime(
                    context: context,
                    l10n: l10n,
                    controller: controller,
                    settings: settings.nightReaderSettings,
                    isStart: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SettingsSectionCard(
            title: l10n.notificationsSettingsTitle,
            child: ListTile(
              key: const Key('settings-notifications-entry'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsNotificationsEntryTitle),
              subtitle: Text(l10n.settingsNotificationsEntrySubtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/more/settings/notifications'),
            ),
          ),
        ],
      ),
    );
  }
}

String _buildNightReaderSummary(
  BuildContext context,
  AppLocalizations l10n,
  NightReaderSettings settings,
) {
  final statusLabel = settings.autoEnable
      ? l10n.settingsNightReaderAutoEnableOn
      : l10n.settingsNightReaderAutoEnableOff;
  final startLabel = _formatNightReaderMinutes(context, settings.startMinutes);
  final endLabel = _formatNightReaderMinutes(context, settings.endMinutes);
  final styleLabel = switch (settings.preferredStyle) {
    ReaderNightStyle.night => l10n.settingsNightReaderStyleNight,
    ReaderNightStyle.amoled => l10n.settingsNightReaderStyleAmoled,
  };

  return '$statusLabel • $startLabel -> $endLabel • $styleLabel';
}

TimeOfDay _timeOfDayFromMinutes(int minutes) {
  return TimeOfDay(
    hour: minutes ~/ 60,
    minute: minutes % 60,
  );
}

String _formatNightReaderMinutes(BuildContext context, int minutes) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    _timeOfDayFromMinutes(minutes),
  );
}

Future<void> _selectNightReaderTime({
  required BuildContext context,
  required AppLocalizations l10n,
  required AppSettingsController controller,
  required NightReaderSettings settings,
  required bool isStart,
}) async {
  final selectedTime = await showTimePicker(
    context: context,
    initialTime: _timeOfDayFromMinutes(
      isStart ? settings.startMinutes : settings.endMinutes,
    ),
  );
  if (selectedTime == null || !context.mounted) {
    return;
  }

  final selectedMinutes = (selectedTime.hour * 60) + selectedTime.minute;
  final startMinutes = isStart ? selectedMinutes : settings.startMinutes;
  final endMinutes = isStart ? settings.endMinutes : selectedMinutes;
  if (!ReaderNightSchedulePolicy.isValidWindow(
    startMinutes: startMinutes,
    endMinutes: endMinutes,
  )) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsNightReaderInvalidSchedule),
      ),
    );
    return;
  }

  await controller.setNightReaderSchedule(
    startMinutes: startMinutes,
    endMinutes: endMinutes,
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      key: chipKey,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.gold.withValues(alpha: 0.22),
      labelStyle: TextStyle(
        color: selected ? AppColors.gold : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.18),
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark.withValues(alpha: 0.55)
          : Colors.white,
      showCheckmark: false,
    );
  }
}
