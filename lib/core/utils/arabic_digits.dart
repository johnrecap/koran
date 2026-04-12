String toArabicDigits(int value) {
  const digits = <String>[
    '\u0660',
    '\u0661',
    '\u0662',
    '\u0663',
    '\u0664',
    '\u0665',
    '\u0666',
    '\u0667',
    '\u0668',
    '\u0669',
  ];

  return value.toString().split('').map((character) {
    if (character == '-') {
      return character;
    }

    return digits[int.parse(character)];
  }).join();
}
