import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bundles the stories index in the root asset bundle',
      (tester) async {
    final bundledIndex = await rootBundle.loadString('assets/stories/_index.json');

    expect(bundledIndex, contains('"id"'));
    expect(bundledIndex, contains('"file"'));
  });
}
