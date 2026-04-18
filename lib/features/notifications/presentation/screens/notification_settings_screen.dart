import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/notifications/domain/notification_permission_state.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/presentation/widgets/notification_family_tile.dart';
import 'package:quran_kareem/features/notifications/presentation/widgets/notification_permission_card.dart';
import 'package:quran_kareem/features/notifications/presentation/widgets/notification_time_picker_tile.dart';
import 'package:quran_kareem/features/notifications/presentation/widgets/adhan_sound_picker.dart';
import 'package:quran_kareem/features/notifications/providers/notification_providers.dart';
import 'package:quran_kareem/features/settings/presentation/widgets/settings_section_card.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permissionState = ref.watch(notificationPermissionControllerProvider);
    final preferences = ref.watch(notificationPreferencesControllerProvider);
    final controller =
        ref.read(notificationPreferencesControllerProvider.notifier);
    final permissionController =
        ref.read(notificationPermissionControllerProvider.notifier);
    final prayerSnapshot = ref.watch(homePrayerSnapshotProvider).valueOrNull;
    final reviewItems = ref.watch(spacedReviewItemsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(l10n.notificationsSettingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        children: [
          NotificationPermissionCard(
            title: _permissionTitle(permissionState, l10n),
            message: _permissionMessage(permissionState, l10n),
            ctaLabel: l10n.notificationsPermissionRequestAction,
            showAction: permissionState.canRequestPermission,
            onPressed: () => permissionController.requestPermission(),
          ),
          const SizedBox(height: 18),
          SettingsSectionCard(
            title: l10n.notificationsSettingsFamiliesTitle,
            child: Column(
              children: [
                NotificationFamilyTile(
                  key: const Key('notification-family-dailyWird'),
                  title: l10n.notificationsFamilyDailyWirdTitle,
                  subtitle: l10n.notificationsFamilyDailyWirdSubtitle,
                  value: preferences.dailyWird.enabled,
                  onChanged: (value) => controller.setReminderEnabled(
                    NotificationReminderType.dailyWird,
                    value,
                  ),
                  statusText: _familyStatusText(
                    reminderType: NotificationReminderType.dailyWird,
                    permissionState: permissionState,
                    prayerReady: prayerSnapshot != null,
                    hasReviewItems: reviewItems.isNotEmpty,
                    l10n: l10n,
                  ),
                  child: preferences.dailyWird.time == null
                      ? null
                      : NotificationTimePickerTile(
                          key: const Key('notification-family-dailyWird-time'),
                          label: l10n.notificationsTimeLabel,
                          time: preferences.dailyWird.time!,
                          onPressed: () => _pickTime(
                            context: context,
                            initialTime: preferences.dailyWird.time!,
                            onSelected: (time) {
                              return controller.setDailyReminderTime(
                                NotificationReminderType.dailyWird,
                                time,
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                NotificationFamilyTile(
                  key: const Key('notification-family-adhkar'),
                  title: l10n.notificationsFamilyAdhkarTitle,
                  subtitle: l10n.notificationsFamilyAdhkarSubtitle,
                  value: preferences.adhkar.enabled,
                  onChanged: (value) => controller.setReminderEnabled(
                    NotificationReminderType.adhkar,
                    value,
                  ),
                  statusText: _familyStatusText(
                    reminderType: NotificationReminderType.adhkar,
                    permissionState: permissionState,
                    prayerReady: prayerSnapshot != null,
                    hasReviewItems: reviewItems.isNotEmpty,
                    l10n: l10n,
                  ),
                  child: preferences.adhkar.time == null
                      ? null
                      : NotificationTimePickerTile(
                          key: const Key('notification-family-adhkar-time'),
                          label: l10n.notificationsTimeLabel,
                          time: preferences.adhkar.time!,
                          onPressed: () => _pickTime(
                            context: context,
                            initialTime: preferences.adhkar.time!,
                            onSelected: (time) {
                              return controller.setDailyReminderTime(
                                NotificationReminderType.adhkar,
                                time,
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                NotificationFamilyTile(
                  key: const Key('notification-family-fridayKahf'),
                  title: l10n.notificationsFamilyFridayKahfTitle,
                  subtitle: l10n.notificationsFamilyFridayKahfSubtitle,
                  value: preferences.fridayKahf.enabled,
                  onChanged: (value) => controller.setReminderEnabled(
                    NotificationReminderType.fridayKahf,
                    value,
                  ),
                  statusText: _familyStatusText(
                    reminderType: NotificationReminderType.fridayKahf,
                    permissionState: permissionState,
                    prayerReady: prayerSnapshot != null,
                    hasReviewItems: reviewItems.isNotEmpty,
                    l10n: l10n,
                  ),
                  child: preferences.fridayKahf.time == null
                      ? null
                      : NotificationTimePickerTile(
                          key: const Key('notification-family-fridayKahf-time'),
                          label: l10n.notificationsTimeLabel,
                          time: preferences.fridayKahf.time!,
                          onPressed: () => _pickTime(
                            context: context,
                            initialTime: preferences.fridayKahf.time!,
                            onSelected: (time) {
                              return controller.setDailyReminderTime(
                                NotificationReminderType.fridayKahf,
                                time,
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                NotificationFamilyTile(
                  key: const Key('notification-family-prayer'),
                  title: l10n.notificationsFamilyPrayerTitle,
                  subtitle: l10n.notificationsFamilyPrayerSubtitle,
                  value: preferences.prayer.enabled,
                  onChanged: (value) => controller.setReminderEnabled(
                    NotificationReminderType.prayer,
                    value,
                  ),
                  statusText: _familyStatusText(
                    reminderType: NotificationReminderType.prayer,
                    permissionState: permissionState,
                    prayerReady: prayerSnapshot != null,
                    hasReviewItems: reviewItems.isNotEmpty,
                    l10n: l10n,
                  ),
                  child: _PrayerReminderOffsetTile(
                    valueLabel: _prayerReminderOffsetLabel(
                      context,
                      preferences.prayerReminderOffset,
                    ),
                    onPressed: () => _showPrayerReminderOffsetSheet(
                      context: context,
                      selected: preferences.prayerReminderOffset,
                      onSelected: controller.setPrayerReminderOffset,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // ── Adhan settings (visible when prayer toggle is on) ──
                if (preferences.prayer.enabled) const AdhanSoundPicker(),
                const SizedBox(height: 14),
                NotificationFamilyTile(
                  key: const Key('notification-family-review'),
                  title: l10n.notificationsFamilyReviewTitle,
                  subtitle: l10n.notificationsFamilyReviewSubtitle,
                  value: preferences.spacedReview.enabled,
                  onChanged: (value) => controller.setReminderEnabled(
                    NotificationReminderType.spacedReview,
                    value,
                  ),
                  statusText: _familyStatusText(
                    reminderType: NotificationReminderType.spacedReview,
                    permissionState: permissionState,
                    prayerReady: prayerSnapshot != null,
                    hasReviewItems: reviewItems.isNotEmpty,
                    l10n: l10n,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime({
    required BuildContext context,
    required TimeOfDay initialTime,
    required Future<void> Function(TimeOfDay time) onSelected,
  }) async {
    final result = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (result == null) {
      return;
    }
    await onSelected(result);
  }

  Future<void> _showPrayerReminderOffsetSheet({
    required BuildContext context,
    required PrayerReminderOffset selected,
    required Future<void> Function(PrayerReminderOffset offset) onSelected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final offset in PrayerReminderOffset.values)
                ListTile(
                  key: Key('prayer-reminder-offset-${offset.name}'),
                  title: Text(_prayerReminderOffsetLabel(sheetContext, offset)),
                  trailing: offset == selected
                      ? const Icon(Icons.check_rounded, color: AppColors.gold)
                      : null,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await onSelected(offset);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _prayerReminderOffsetLabel(
    BuildContext context,
    PrayerReminderOffset offset,
  ) {
    final l10n = context.l10n;
    return switch (offset) {
      PrayerReminderOffset.atAdhan => l10n.prayerReminderAtAdhan,
      PrayerReminderOffset.fiveMinBefore =>
        l10n.prayerReminderMinsBefore('5'),
      PrayerReminderOffset.tenMinBefore =>
        l10n.prayerReminderMinsBefore('10'),
      PrayerReminderOffset.fifteenMinBefore =>
        l10n.prayerReminderMinsBefore('15'),
      PrayerReminderOffset.thirtyMinBefore =>
        l10n.prayerReminderMinsBefore('30'),
    };
  }

  String _permissionTitle(
    NotificationPermissionState permissionState,
    AppLocalizations l10n,
  ) {
    return switch (permissionState) {
      NotificationPermissionState.unknown =>
        l10n.notificationsPermissionUnknownTitle,
      NotificationPermissionState.granted =>
        l10n.notificationsPermissionGrantedTitle,
      NotificationPermissionState.denied =>
        l10n.notificationsPermissionDeniedTitle,
      NotificationPermissionState.blocked =>
        l10n.notificationsPermissionBlockedTitle,
      NotificationPermissionState.unavailable =>
        l10n.notificationsPermissionUnavailableTitle,
    };
  }

  String _permissionMessage(
    NotificationPermissionState permissionState,
    AppLocalizations l10n,
  ) {
    return switch (permissionState) {
      NotificationPermissionState.unknown =>
        l10n.notificationsPermissionUnknownBody,
      NotificationPermissionState.granted =>
        l10n.notificationsPermissionGrantedBody,
      NotificationPermissionState.denied =>
        l10n.notificationsPermissionDeniedBody,
      NotificationPermissionState.blocked =>
        l10n.notificationsPermissionBlockedBody,
      NotificationPermissionState.unavailable =>
        l10n.notificationsPermissionUnavailableBody,
    };
  }

  String? _familyStatusText({
    required NotificationReminderType reminderType,
    required NotificationPermissionState permissionState,
    required bool prayerReady,
    required bool hasReviewItems,
    required AppLocalizations l10n,
  }) {
    if (!permissionState.isGranted) {
      return l10n.notificationsFamilyStatusPermissionRequired;
    }

    return switch (reminderType) {
      NotificationReminderType.prayer =>
        prayerReady ? null : l10n.notificationsFamilyStatusPrayerUnavailable,
      NotificationReminderType.spacedReview =>
        hasReviewItems ? null : l10n.notificationsFamilyStatusReviewWaiting,
      NotificationReminderType.dailyWird => null,
      NotificationReminderType.fridayKahf => null,
      NotificationReminderType.adhkar => null,
    };
  }
}

class _PrayerReminderOffsetTile extends StatelessWidget {
  const _PrayerReminderOffsetTile({
    required this.valueLabel,
    required this.onPressed,
  });

  final String valueLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      key: const Key('notification-family-prayer-offset'),
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.prayerReminderOffsetLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valueLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}
