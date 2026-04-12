/// Barrel re-export for backwards compatibility.
///
/// After the feature module split, prayer, adhkar, and qibla providers live in
/// their own feature packages. This file re-exports them so that existing
/// importers of `more_providers.dart` continue to compile.
///
/// New code should import directly from the feature-specific providers:
/// - `package:quran_kareem/features/prayer/providers/prayer_providers.dart`
/// - `package:quran_kareem/features/adhkar/providers/adhkar_providers.dart`
/// - `package:quran_kareem/features/qibla/providers/qibla_providers.dart`
library;

export 'package:quran_kareem/features/prayer/providers/prayer_providers.dart';
export 'package:quran_kareem/features/qibla/providers/qibla_providers.dart';
