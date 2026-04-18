import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_playback_mode.dart';
import 'package:quran_kareem/features/notifications/providers/notification_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

/// Displays the adhan settings section: playback mode toggle and muezzin
/// selection with preview/download controls.
class AdhanSoundPicker extends ConsumerStatefulWidget {
  const AdhanSoundPicker({super.key});

  @override
  ConsumerState<AdhanSoundPicker> createState() => _AdhanSoundPickerState();
}

class _AdhanSoundPickerState extends ConsumerState<AdhanSoundPicker> {
  AdhanMuezzin? _previewingMuezzin;
  AdhanMuezzin? _downloadingMuezzin;
  final Map<AdhanMuezzin, bool> _downloadedStatus = {};

  @override
  void initState() {
    super.initState();
    _checkAllDownloadStatus();
  }

  Future<void> _checkAllDownloadStatus() async {
    final cacheService = ref.read(adhanAudioCacheServiceProvider);
    for (final muezzin in AdhanMuezzin.values) {
      final cached = await cacheService.getCachedFile(muezzin);
      if (mounted) {
        setState(() {
          _downloadedStatus[muezzin] = cached != null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(notificationPreferencesControllerProvider);
    final locale = ref.watch(appSettingsControllerProvider).locale;
    final l10n = AppLocalizations(locale);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.notificationsAdhanSectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ── Playback mode selector ──
        ListTile(
          leading: Icon(Icons.volume_up, color: colorScheme.primary),
          title: Text(l10n.notificationsAdhanPlaybackModeLabel),
          subtitle: Text(_playbackModeLabel(prefs.adhanPlaybackMode, l10n)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPlaybackModePicker(context, prefs, l10n),
        ),

        // ── Muezzin selector (only shown when not notification-only) ──
        if (prefs.adhanPlaybackMode != AdhanPlaybackMode.notificationOnly) ...[
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.mic, color: colorScheme.primary),
            title: Text(l10n.notificationsAdhanMuezzinLabel),
            subtitle: Text(prefs.selectedMuezzin.label(l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMuezzinPicker(context, prefs, l10n),
          ),
        ],
      ],
    );
  }

  String _playbackModeLabel(AdhanPlaybackMode mode, AppLocalizations l10n) {
    return switch (mode) {
      AdhanPlaybackMode.notificationOnly =>
        l10n.notificationsAdhanPlaybackNotificationOnly,
      AdhanPlaybackMode.fullAdhan => l10n.notificationsAdhanPlaybackFullAdhan,
      AdhanPlaybackMode.takbeerOnly =>
        l10n.notificationsAdhanPlaybackTakbeerOnly,
    };
  }

  void _showPlaybackModePicker(
    BuildContext context,
    dynamic prefs,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<AdhanPlaybackMode>(
                groupValue: prefs.adhanPlaybackMode,
                onChanged: (selected) {
                  if (selected != null) {
                    ref
                        .read(notificationPreferencesControllerProvider
                            .notifier)
                        .setAdhanPlaybackMode(selected);
                    Navigator.of(sheetContext).pop();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final mode in AdhanPlaybackMode.values)
                      RadioListTile<AdhanPlaybackMode>(
                        title: Text(_playbackModeLabel(mode, l10n)),
                        value: mode,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showMuezzinPicker(
    BuildContext context,
    dynamic prefs,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setSheetState) {
            return SafeArea(
              child: DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.3,
                maxChildSize: 0.85,
                expand: false,
                builder: (dragContext, scrollController) {
                  final colorScheme =
                      Theme.of(dragContext).colorScheme;
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.notificationsAdhanMuezzinLabel,
                          style: Theme.of(dragContext)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: RadioGroup<AdhanMuezzin>(
                          groupValue: prefs.selectedMuezzin,
                          onChanged: (selected) {
                            if (selected != null) {
                              ref
                                  .read(
                                      notificationPreferencesControllerProvider
                                          .notifier)
                                  .setSelectedMuezzin(selected);
                            }
                          },
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: AdhanMuezzin.values.length,
                            itemBuilder: (listContext, index) {
                              final muezzin = AdhanMuezzin.values[index];
                              final isSelected =
                                  muezzin == prefs.selectedMuezzin;
                              final isDownloaded =
                                  _downloadedStatus[muezzin] ?? false;
                              final isPreviewing =
                                  _previewingMuezzin == muezzin;
                              final isDownloading =
                                  _downloadingMuezzin == muezzin;

                              return ListTile(
                                leading: Radio<AdhanMuezzin>(
                                  value: muezzin,
                                ),
                              title: Text(
                                muezzin.label(l10n),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: isDownloaded
                                  ? Text(
                                      l10n.notificationsAdhanDownloaded,
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Preview button
                                  IconButton(
                                    icon: Icon(
                                      isPreviewing
                                          ? Icons.stop_circle
                                          : Icons.play_circle_outline,
                                      color: colorScheme.primary,
                                    ),
                                    tooltip: l10n.notificationsAdhanPreview,
                                    onPressed: () => _togglePreview(
                                      muezzin,
                                      setSheetState,
                                    ),
                                  ),
                                  // Download button
                                  if (isDownloading)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else if (!isDownloaded)
                                    IconButton(
                                      icon: Icon(
                                        Icons.download,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: () => _downloadMuezzin(
                                        muezzin,
                                        setSheetState,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.check_circle,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                ],
                              ),
                              onTap: () {
                                ref
                                    .read(
                                        notificationPreferencesControllerProvider
                                            .notifier)
                                    .setSelectedMuezzin(muezzin);
                              },
                            );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _togglePreview(
    AdhanMuezzin muezzin,
    void Function(void Function()) setSheetState,
  ) async {
    final playbackService = ref.read(adhanAudioPlaybackServiceProvider);

    if (_previewingMuezzin == muezzin) {
      await playbackService.stop();
      setState(() => _previewingMuezzin = null);
      setSheetState(() {});
      return;
    }

    setState(() => _previewingMuezzin = muezzin);
    setSheetState(() {});

    final success = await playbackService.preview(muezzin);
    if (!success && mounted) {
      setState(() => _previewingMuezzin = null);
      setSheetState(() {});
    }

    // Auto-reset preview state when playback completes.
    playbackService.playingStream.listen((playing) {
      if (!playing && mounted && _previewingMuezzin == muezzin) {
        setState(() => _previewingMuezzin = null);
        // Only call setSheetState if the sheet is still open.
        try {
          setSheetState(() {});
        } on Object {
          // Sheet may have been dismissed.
        }
      }
    });
  }

  Future<void> _downloadMuezzin(
    AdhanMuezzin muezzin,
    void Function(void Function()) setSheetState,
  ) async {
    setState(() => _downloadingMuezzin = muezzin);
    setSheetState(() {});

    try {
      final cacheService = ref.read(adhanAudioCacheServiceProvider);
      await cacheService.download(muezzin);
      if (mounted) {
        setState(() {
          _downloadedStatus[muezzin] = true;
          _downloadingMuezzin = null;
        });
        setSheetState(() {});
      }
    } on Object {
      if (mounted) {
        setState(() => _downloadingMuezzin = null);
        setSheetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations(
                ref.read(appSettingsControllerProvider).locale,
              ).notificationsAdhanDownloadFailed,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Stop preview if playing.
    ref.read(adhanAudioPlaybackServiceProvider).stop();
    super.dispose();
  }
}
