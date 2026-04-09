enum NotificationReminderType {
  dailyWird,
  prayer,
  fridayKahf,
  spacedReview,
  adhkar,
}

extension NotificationReminderTypeX on NotificationReminderType {
  bool get usesCustomTime {
    return switch (this) {
      NotificationReminderType.dailyWird => true,
      NotificationReminderType.prayer => false,
      NotificationReminderType.fridayKahf => true,
      NotificationReminderType.spacedReview => false,
      NotificationReminderType.adhkar => true,
    };
  }
}
