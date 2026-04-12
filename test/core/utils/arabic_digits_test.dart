import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/utils/arabic_digits.dart';

void main() {
  test('converts western digits to Arabic-Indic digits', () {
    expect(
      toArabicDigits(1209),
      '\u0661\u0662\u0660\u0669',
    );
  });
}
