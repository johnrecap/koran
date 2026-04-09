import 'package:quran_kareem/features/more/domain/adhkar_counter_state.dart';
import 'package:quran_kareem/features/more/domain/adhkar_models.dart';

class AdhkarCategorySection {
  const AdhkarCategorySection({
    required this.id,
    required this.categories,
  });

  final String id;
  final List<AdhkarCategory> categories;
}

abstract final class AdhkarPolicies {
  static const List<int> counterTargets = <int>[33, 100];

  static const List<String> _groupOrder = <String>[
    'dailyCore',
    'heartWork',
    'lifeNeeds',
    'sourceLed',
  ];

  static const List<String> _categoryOrder = <String>[
    'morning',
    'evening',
    'afterPrayer',
    'sleep',
    'waking',
    'istighfar',
    'rizq',
    'distress',
    'travel',
    'quranDuas',
    'sunnahDuas',
  ];

  static List<AdhkarCategorySection> buildSections(
    List<AdhkarCategory> categories,
  ) {
    final byGroup = <String, List<AdhkarCategory>>{};
    for (final category in categories) {
      byGroup.putIfAbsent(category.groupId, () => <AdhkarCategory>[]).add(
            category,
          );
    }

    final sections = <AdhkarCategorySection>[];
    for (final groupId in _groupOrder) {
      final groupCategories = byGroup.remove(groupId);
      if (groupCategories == null || groupCategories.isEmpty) {
        continue;
      }
      sections.add(
        AdhkarCategorySection(
          id: groupId,
          categories: sortCategories(groupCategories),
        ),
      );
    }

    final remainingGroupIds = byGroup.keys.toList()..sort();
    for (final groupId in remainingGroupIds) {
      sections.add(
        AdhkarCategorySection(
          id: groupId,
          categories: sortCategories(byGroup[groupId]!),
        ),
      );
    }

    return sections;
  }

  static List<AdhkarCategory> sortCategories(Iterable<AdhkarCategory> input) {
    final categories = input.toList(growable: false);
    final order = <String, int>{
      for (var index = 0; index < _categoryOrder.length; index += 1)
        _categoryOrder[index]: index,
    };

    final sorted = categories.toList(growable: false)
      ..sort((left, right) {
        final leftRank = order[left.id] ?? 999;
        final rightRank = order[right.id] ?? 999;
        if (leftRank != rightRank) {
          return leftRank.compareTo(rightRank);
        }
        return left.id.compareTo(right.id);
      });

    return sorted;
  }

  static double? counterProgress(AdhkarCounterState state) {
    final target = state.target;
    if (target == null || target <= 0) {
      return null;
    }

    final progress = state.count / target;
    if (progress < 0) {
      return 0;
    }
    if (progress > 1) {
      return 1;
    }
    return progress;
  }
}
