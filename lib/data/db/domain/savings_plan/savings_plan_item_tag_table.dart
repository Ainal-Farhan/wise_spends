import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_item_table.dart';

/// Savings Plan Item Tag table for optional categorization of budget items.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// This is a join table that allows multiple tags per item.
/// Tags are free-text but pre-defined suggestions can be provided in the UI.
///
/// Example tags: "Pelamin", "Hantaran", "Makeup", "Photography", "Catering"
@DataClassName("${DomainTableConstant.savingsPlanTablePrefix}ItemTag")
class SavingsPlanItemTagTable extends BaseEntityTable {
  /// FK to [SavingsPlanItemTable] — the item this tag belongs to.
  TextColumn get itemId => text().references(SavingsPlanItemTable, #id)();

  /// Tag name (e.g., "Pelamin", "Hantaran", "Makeup").
  TextColumn get tagName => text().withLength(min: 1, max: 50)();

  @override
  List<Set<Column>> get uniqueKeys => [
    // Prevent duplicate tags for the same item
    {itemId, tagName},
  ];

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'itemId': itemId.name,
    'tagName': tagName.name,
  };
}
