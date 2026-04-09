import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('BasmalaStyle', () {
    test('merge preserves local defaults for unspecified override fields', () {
      final resolved = BasmalaStyle(
        basmalaColor: Colors.black,
        basmalaFontSize: 23,
        verticalPadding: 0,
      ).merge(
        BasmalaStyle(
          basmalaColor: Colors.white,
        ),
      );

      expect(resolved.basmalaColor, Colors.white);
      expect(resolved.basmalaFontSize, 23);
      expect(resolved.verticalPadding, 0);
    });

    test('merge applies explicit size and padding overrides', () {
      final resolved = BasmalaStyle(
        basmalaColor: Colors.black,
        basmalaFontSize: 23,
        verticalPadding: 0,
      ).merge(
        BasmalaStyle(
          basmalaColor: Colors.white,
          basmalaFontSize: 31,
          verticalPadding: 12,
        ),
      );

      expect(resolved.basmalaColor, Colors.white);
      expect(resolved.basmalaFontSize, 31);
      expect(resolved.verticalPadding, 12);
    });
  });
}
