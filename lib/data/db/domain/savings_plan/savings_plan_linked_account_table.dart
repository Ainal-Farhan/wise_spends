import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';

/// Savings Plan Linked Account table for tracking which savings accounts
/// contribute to a savings plan.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
@DataClassName("${DomainTableConstant.savingsPlanTablePrefix}LinkedAccount")
class SavingsPlanLinkedAccountTable extends BaseEntityTable {
  /// FK to [SavingsPlanTable] — the plan this account is linked to.
  TextColumn get planId => text().references(SavingsPlanTable, #id)();

  /// FK to [SavingTable] — the savings account being linked.
  TextColumn get accountId => text().references(SavingTable, #id)();

  /// Optional percentage of the account balance allocated to this plan.
  RealColumn get allocatedPercentage => real().nullable()();

  /// When the account was linked.
  DateTimeColumn get linkedAt => dateTime().withDefault(currentDateAndTime)();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  @override
  List<Set<Column>> get uniqueKeys => [
    // Prevent duplicate links
    {planId, accountId},
  ];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'planId': planId.name,
    'accountId': accountId.name,
    'allocatedPercentage': allocatedPercentage.name,
    'linkedAt': linkedAt.name,
  };
}
