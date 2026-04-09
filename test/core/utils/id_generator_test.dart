import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/utils/id_generator.dart';

void main() {
  test('uniqueId generates distinct values across rapid calls', () {
    final ids = <String>{
      for (var index = 0; index < 100; index += 1) IdGenerator.uniqueId(),
    };

    expect(ids, hasLength(100));
  });
}
