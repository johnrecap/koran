import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_kareem/features/more/domain/adhkar_models.dart';

abstract class AdhkarCatalogSource {
  Future<AdhkarCatalog> loadCatalog();
}

class AssetAdhkarCatalogSource implements AdhkarCatalogSource {
  AssetAdhkarCatalogSource({
    AssetBundle? bundle,
    this.assetPath = 'assets/adhkar/adhkar_catalog.json',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String assetPath;

  @override
  Future<AdhkarCatalog> loadCatalog() async {
    final raw = await bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Adhkar catalog must decode to a map.');
    }

    return AdhkarCatalog.fromMap(decoded);
  }
}
