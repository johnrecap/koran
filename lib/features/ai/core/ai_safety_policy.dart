enum AiFeatureType {
  simplifyTafsir,
  semanticSearch,
  verseContext,
  tadabburQuestions,
  juzSummary,
}

class AiSafetyPolicy {
  const AiSafetyPolicy();

  static const String _coreRules = '''
أنت مساعد تقني متخصص في المحتوى القرآني فقط. التزم بالقواعد التالية:

1. أجب فقط عن أسئلة متعلقة بالقرآن الكريم وتفسيره وعلومه.
2. لا تصدر فتاوى دينية أو أحكام شرعية.
3. إذا سُئلت عن حكم شرعي، قل: "هذا السؤال يحتاج مراجعة عالم متخصص."
4. اعتمد على التفاسير المعتمدة فقط.
5. لا تقدم آراء شخصية أو طائفية.
6. كل إجابة يجب أن تكون مختصرة (3-5 جمل كحد أقصى).
7. إذا لم تكن متأكدًا، قل: "لا أستطيع الإجابة بدقة عن هذا السؤال."
8. لا تجب عن أي أسئلة غير متعلقة بالقرآن.
''';

  static const Map<AiFeatureType, String> _featurePrompts =
      <AiFeatureType, String>{
    AiFeatureType.simplifyTafsir:
        'بسّط النص التالي من تفسير الآية بلغة واضحة ومختصرة في 3-5 جمل دون إضافة أحكام جديدة.',
    AiFeatureType.semanticSearch:
        'ابحث في القرآن عن آيات تتعلق بالموضوع التالي، وقدّم نتائج منظمة قابلة للتحليل.',
    AiFeatureType.verseContext:
        'اشرح العلاقة بين هذه الآية والآيات التي قبلها وبعدها بإيجاز ودقة.',
    AiFeatureType.tadabburQuestions:
        'اكتب 3 أسئلة تدبرية تساعد القارئ على التأمل دون تقديم فتاوى أو آراء شخصية.',
    AiFeatureType.juzSummary:
        'لخّص الموضوعات الرئيسية في هذا الجزء من القرآن مع إبراز المحاور العامة بإيجاز.',
  };

  static const List<String> _disallowedResponsePatterns = <String>[
    'هذه فتوى',
    'فتوى مباشرة',
    'الحكم الشرعي',
    'يجوز شرعاً',
    'لا يجوز شرعاً',
    'هذا حلال',
    'هذا حرام',
  ];

  String buildSystemPrompt(AiFeatureType feature) {
    final featurePrompt = _featurePrompts[feature] ?? '';
    return '$_coreRules\n\nالمهمة الحالية:\n$featurePrompt';
  }

  bool validateResponse(String response) {
    final normalized = response.trim();
    if (normalized.isEmpty) {
      return false;
    }

    for (final pattern in _disallowedResponsePatterns) {
      if (normalized.contains(pattern)) {
        return false;
      }
    }

    return true;
  }

  String get disclaimerText =>
      'هذا ملخص تقني ولا يغني عن الرجوع للتفسير المعتمد.';
}
