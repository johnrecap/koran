import 'package:flutter/material.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';

class NotificationReminderPreference {
  const NotificationReminderPreference({
    required this.enabled,
    this.time,
  });

  final bool enabled;
  final TimeOfDay? time;

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'hour': time?.hour,
        'minute': time?.minute,
      };

  factory NotificationReminderPreference.fromMap(
    Map<String, dynamic>? map, {
    required NotificationReminderPreference fallback,
  }) {
    if (map == null) {
      return fallback;
    }

    final hour = map['hour'];
    final minute = map['minute'];
    final hasTime = hour is int && minute is int;

    return NotificationReminderPreference(
      enabled: map['enabled'] as bool? ?? fallback.enabled,
      time: hasTime ? TimeOfDay(hour: hour, minute: minute) : fallback.time,
    );
  }

  NotificationReminderPreference copyWith({
    bool? enabled,
    TimeOfDay? time,
    bool clearTime = false,
  }) {
    return NotificationReminderPreference(
      enabled: enabled ?? this.enabled,
      time: clearTime ? null : time ?? this.time,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NotificationReminderPreference &&
        other.enabled == enabled &&
        other.time == time;
  }

  @override
  int get hashCode => Object.hash(enabled, time);
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.dailyWird,
    required this.prayer,
    this.prayerReminderOffset = PrayerReminderOffset.fifteenMinBefore,
    required this.fridayKahf,
    required this.spacedReview,
    required this.adhkar,
  });

  const NotificationPreferences.defaults()
      : dailyWird = const NotificationReminderPreference(
          enabled: false,
          time: TimeOfDay(hour: 8, minute: 0),
        ),
        prayer = const NotificationReminderPreference(enabled: false),
        prayerReminderOffset = PrayerReminderOffset.fifteenMinBefore,
        fridayKahf = const NotificationReminderPreference(
          enabled: false,
          time: TimeOfDay(hour: 9, minute: 0),
        ),
        spacedReview = const NotificationReminderPreference(enabled: false),
        adhkar = const NotificationReminderPreference(
          enabled: false,
          time: TimeOfDay(hour: 18, minute: 0),
        );

  final NotificationReminderPreference dailyWird;
  final NotificationReminderPreference prayer;
  final PrayerReminderOffset prayerReminderOffset;
  final NotificationReminderPreference fridayKahf;
  final NotificationReminderPreference spacedReview;
  final NotificationReminderPreference adhkar;

  Map<String, dynamic> toMap() => {
        'dailyWird': dailyWird.toMap(),
        'prayer': prayer.toMap(),
        'prayerReminderOffset': prayerReminderOffset.name,
        'fridayKahf': fridayKahf.toMap(),
        'spacedReview': spacedReview.toMap(),
        'adhkar': adhkar.toMap(),
      };

  factory NotificationPreferences.fromMap(Map<String, dynamic>? map) {
    const defaults = NotificationPreferences.defaults();
    if (map == null) {
      return defaults;
    }

    return NotificationPreferences(
      dailyWird: NotificationReminderPreference.fromMap(
        map['dailyWird'] as Map<String, dynamic>?,
        fallback: defaults.dailyWird,
      ),
      prayer: NotificationReminderPreference.fromMap(
        map['prayer'] as Map<String, dynamic>?,
        fallback: defaults.prayer,
      ),
      prayerReminderOffset: PrayerReminderOffset.fromName(
        map['prayerReminderOffset'] as String?,
      ),
      fridayKahf: NotificationReminderPreference.fromMap(
        map['fridayKahf'] as Map<String, dynamic>?,
        fallback: defaults.fridayKahf,
      ),
      spacedReview: NotificationReminderPreference.fromMap(
        map['spacedReview'] as Map<String, dynamic>?,
        fallback: defaults.spacedReview,
      ),
      adhkar: NotificationReminderPreference.fromMap(
        map['adhkar'] as Map<String, dynamic>?,
        fallback: defaults.adhkar,
      ),
    );
  }

  NotificationReminderPreference family(NotificationReminderType reminderType) {
    return switch (reminderType) {
      NotificationReminderType.dailyWird => dailyWird,
      NotificationReminderType.prayer => prayer,
      NotificationReminderType.fridayKahf => fridayKahf,
      NotificationReminderType.spacedReview => spacedReview,
      NotificationReminderType.adhkar => adhkar,
    };
  }

  bool isEnabled(NotificationReminderType reminderType) {
    return family(reminderType).enabled;
  }

  TimeOfDay? configuredTime(NotificationReminderType reminderType) {
    return family(reminderType).time;
  }

  NotificationPreferences copyWithFamilyEnabled(
    NotificationReminderType reminderType,
    bool enabled,
  ) {
    return _replaceFamily(
      reminderType,
      family(reminderType).copyWith(enabled: enabled),
    );
  }

  NotificationPreferences copyWithFamilyTime(
    NotificationReminderType reminderType,
    TimeOfDay time,
  ) {
    return _replaceFamily(
      reminderType,
      family(reminderType).copyWith(time: time),
    );
  }

  NotificationPreferences copyWithPrayerReminderOffset(
    PrayerReminderOffset offset,
  ) {
    return NotificationPreferences(
      dailyWird: dailyWird,
      prayer: prayer,
      prayerReminderOffset: offset,
      fridayKahf: fridayKahf,
      spacedReview: spacedReview,
      adhkar: adhkar,
    );
  }

  NotificationPreferences _replaceFamily(
    NotificationReminderType reminderType,
    NotificationReminderPreference next,
  ) {
    return NotificationPreferences(
      dailyWird:
          reminderType == NotificationReminderType.dailyWird ? next : dailyWird,
      prayer: reminderType == NotificationReminderType.prayer ? next : prayer,
      prayerReminderOffset: prayerReminderOffset,
      fridayKahf: reminderType == NotificationReminderType.fridayKahf
          ? next
          : fridayKahf,
      spacedReview: reminderType == NotificationReminderType.spacedReview
          ? next
          : spacedReview,
      adhkar: reminderType == NotificationReminderType.adhkar ? next : adhkar,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NotificationPreferences &&
        other.dailyWird == dailyWird &&
        other.prayer == prayer &&
        other.prayerReminderOffset == prayerReminderOffset &&
        other.fridayKahf == fridayKahf &&
        other.spacedReview == spacedReview &&
        other.adhkar == adhkar;
  }

  @override
  int get hashCode => Object.hash(
        dailyWird,
        prayer,
        prayerReminderOffset,
        fridayKahf,
        spacedReview,
        adhkar,
      );
}
