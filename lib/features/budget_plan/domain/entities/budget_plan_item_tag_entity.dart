import 'package:equatable/equatable.dart';

/// Budget Plan Item Tag Entity - optional categorization for budget items
///
/// Tags allow grouping items by category (e.g., "Pelamin", "Hantaran", "Makeup")
/// without enforcing a rigid category structure. An item can have multiple tags.
class BudgetPlanItemTagEntity extends Equatable {
  final String itemId;
  final String tagName;

  const BudgetPlanItemTagEntity({
    required this.itemId,
    required this.tagName,
  });

  @override
  List<Object?> get props => [itemId, tagName];

  BudgetPlanItemTagEntity copyWith({
    String? itemId,
    String? tagName,
  }) {
    return BudgetPlanItemTagEntity(
      itemId: itemId ?? this.itemId,
      tagName: tagName ?? this.tagName,
    );
  }
}

/// Pre-defined tag suggestions for wedding budgets
/// These are common categories users can select from, with the option to add custom tags.
class BudgetPlanItemTags {
  static const String pelamin = 'Pelamin';
  static const String hantaran = 'Hantaran';
  static const String makeup = 'Makeup';
  static const String photography = 'Photography';
  static const String catering = 'Catering';
  static const String venue = 'Venue';
  static const String attire = 'Attire';
  static const String jewelry = 'Jewelry';
  static const String accommodation = 'Accommodation';
  static const String transportation = 'Transportation';
  static const String entertainment = 'Entertainment';
  static const String gifts = 'Gifts';
  static const String miscellaneous = 'Miscellaneous';

  /// List of all pre-defined tags for UI dropdown/chip selection
  static const List<String> suggestions = [
    pelamin,
    hantaran,
    makeup,
    photography,
    catering,
    venue,
    attire,
    jewelry,
    accommodation,
    transportation,
    entertainment,
    gifts,
    miscellaneous,
  ];
}
