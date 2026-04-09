import 'package:flutter/services.dart';

class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle({
    Map<String, String>? values,
    Map<String, Object>? errors,
  })  : _values = values ?? const <String, String>{},
        _errors = errors ?? const <String, Object>{};

  final Map<String, String> _values;
  final Map<String, Object> _errors;

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final error = _errors[key];
    if (error != null) {
      throw error;
    }

    final value = _values[key];
    if (value == null) {
      throw StateError('Unable to load asset: $key');
    }

    return value;
  }
}
