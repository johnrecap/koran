import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/reader/data/ayah_share_card_export_service.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_template.dart';

final ayahShareCardTemplatesProvider = Provider<List<AyahShareCardTemplate>>((
  ref,
) {
  return AyahShareCardTemplateCatalog.defaults;
});

final ayahShareCardExportServiceProvider =
    Provider<AyahShareCardExportService>((
  ref,
) {
  return const RepaintBoundaryAyahShareCardExportService();
});

final ayahShareCardShareServiceProvider = Provider<AyahShareCardShareService>((
  ref,
) {
  return const SharePlusAyahShareCardShareService();
});
