import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/settings/domain/app_settings_state.dart';

class SettingsPreviewCard extends StatelessWidget {
  const SettingsPreviewCard({
    super.key,
    required this.settings,
  });

  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const LinearGradient(
            colors: <Color>[Color(0xFF241A12), Color(0xFF4D3820)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          )
        : const LinearGradient(
            colors: <Color>[Color(0xFFE8D8BB), Color(0xFFB99153)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          );

    return Container(
      key: const Key('settings-preview-card'),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: background,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsPreviewEyebrow,
              style: const TextStyle(
                color: Color(0xFFF4D686),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.settingsPreviewVerse,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: settings.arabicFontSize,
                height: 1.6,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.settingsPreviewTranslation,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.settingsPreviewHelp,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PreviewPill(label: _themeLabel(l10n, settings.themeMode)),
                _PreviewPill(
                  label: settings.locale.languageCode == 'en'
                      ? l10n.settingsLanguageEnglish
                      : l10n.settingsLanguageArabic,
                ),
                _PreviewPill(
                  label: _readerModeLabel(l10n, settings.defaultReaderMode),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.system => l10n.settingsThemeSystem,
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
    };
  }

  String _readerModeLabel(AppLocalizations l10n, ReaderMode mode) {
    return switch (mode) {
      ReaderMode.scroll => l10n.readerModeScroll,
      ReaderMode.page => l10n.readerModePage,
      ReaderMode.translation => l10n.readerModeTranslation,
    };
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
