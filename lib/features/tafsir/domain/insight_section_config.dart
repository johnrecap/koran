import 'package:flutter/material.dart';

import 'insight_section_models.dart';

class InsightSectionTitleKeys {
  const InsightSectionTitleKeys._();

  static const tafsir = 'insightSectionTafsir';
  static const wordMeaning = 'insightSectionWordMeaning';
  static const asbaab = 'insightSectionAsbaab';
  static const related = 'insightSectionRelated';
}

class InsightSectionConfig {
  const InsightSectionConfig({
    required this.type,
    required this.titleKey,
    required this.icon,
    required this.order,
    this.isAlwaysVisible = false,
  });

  final InsightSectionType type;
  final String titleKey;
  final IconData icon;
  final int order;
  final bool isAlwaysVisible;
}

const tafsirInsightSectionConfig = InsightSectionConfig(
  type: InsightSectionType.tafsir,
  titleKey: InsightSectionTitleKeys.tafsir,
  icon: Icons.menu_book_rounded,
  order: 0,
  isAlwaysVisible: true,
);

const wordMeaningInsightSectionConfig = InsightSectionConfig(
  type: InsightSectionType.wordMeaning,
  titleKey: InsightSectionTitleKeys.wordMeaning,
  icon: Icons.translate_rounded,
  order: 1,
);

const asbaabInsightSectionConfig = InsightSectionConfig(
  type: InsightSectionType.asbaabAlNuzul,
  titleKey: InsightSectionTitleKeys.asbaab,
  icon: Icons.history_edu_rounded,
  order: 2,
);

const relatedAyahsInsightSectionConfig = InsightSectionConfig(
  type: InsightSectionType.relatedAyahs,
  titleKey: InsightSectionTitleKeys.related,
  icon: Icons.link_rounded,
  order: 3,
);

const insightSectionRegistry = <InsightSectionConfig>[
  tafsirInsightSectionConfig,
  wordMeaningInsightSectionConfig,
  asbaabInsightSectionConfig,
  relatedAyahsInsightSectionConfig,
];
