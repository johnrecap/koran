enum NotificationLaunchDestination {
  library,
  prayerDetails,
  adhkar,
  reviewQueue,
  dailyWirdReader,
  fridayKahfReader,
}

class NotificationLaunchTarget {
  const NotificationLaunchTarget._(this.destination);

  const NotificationLaunchTarget.library()
      : this._(NotificationLaunchDestination.library);

  const NotificationLaunchTarget.prayerDetails()
      : this._(NotificationLaunchDestination.prayerDetails);

  const NotificationLaunchTarget.adhkar()
      : this._(NotificationLaunchDestination.adhkar);

  const NotificationLaunchTarget.reviewQueue()
      : this._(NotificationLaunchDestination.reviewQueue);

  const NotificationLaunchTarget.dailyWirdReader()
      : this._(NotificationLaunchDestination.dailyWirdReader);

  const NotificationLaunchTarget.fridayKahfReader()
      : this._(NotificationLaunchDestination.fridayKahfReader);

  final NotificationLaunchDestination destination;

  Map<String, dynamic> toMap() => {
        'destination': destination.name,
      };

  factory NotificationLaunchTarget.fromMap(Map<String, dynamic> map) {
    final rawDestination = map['destination'] as String?;
    final destination = NotificationLaunchDestination.values.firstWhere(
      (value) => value.name == rawDestination,
      orElse: () => NotificationLaunchDestination.library,
    );

    return switch (destination) {
      NotificationLaunchDestination.library =>
        const NotificationLaunchTarget.library(),
      NotificationLaunchDestination.prayerDetails =>
        const NotificationLaunchTarget.prayerDetails(),
      NotificationLaunchDestination.adhkar =>
        const NotificationLaunchTarget.adhkar(),
      NotificationLaunchDestination.reviewQueue =>
        const NotificationLaunchTarget.reviewQueue(),
      NotificationLaunchDestination.dailyWirdReader =>
        const NotificationLaunchTarget.dailyWirdReader(),
      NotificationLaunchDestination.fridayKahfReader =>
        const NotificationLaunchTarget.fridayKahfReader(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NotificationLaunchTarget &&
        other.destination == destination;
  }

  @override
  int get hashCode => destination.hashCode;
}
