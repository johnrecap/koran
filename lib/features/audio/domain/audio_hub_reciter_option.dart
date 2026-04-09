import 'package:flutter/foundation.dart';

@immutable
class AudioHubReciterOption {
  const AudioHubReciterOption({
    required this.index,
    required this.id,
    required this.name,
  });

  final int index;
  final String id;
  final String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AudioHubReciterOption &&
        other.index == index &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(index, id, name);
}
