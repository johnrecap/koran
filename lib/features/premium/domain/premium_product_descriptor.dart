import 'package:flutter/foundation.dart';

@immutable
class PremiumProductDescriptor {
  const PremiumProductDescriptor({
    required this.title,
    required this.subtitle,
    required this.packageId,
  });

  final String title;
  final String subtitle;
  final String packageId;
}
