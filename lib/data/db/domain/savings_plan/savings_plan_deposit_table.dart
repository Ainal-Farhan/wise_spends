import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_table.dart';

/// Savings Plan Deposit table for tracking money added to a savings plan.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// Each deposit increases the [SavingsPlanTable]'s currentAmount.
@DataClassName("${DomainTableConstant.savingsPlanTablePrefix}Deposit")
class SavingsPlanDepositTable extends BaseEntityTable {
  /// FK to [SavingsPlanTable] — the plan this deposit belongs to.
  TextColumn get planId => text().references(SavingsPlanTable, #id)();

  /// Deposit amount (always positive).
  RealColumn get amount => real()();

  /// Optional note about this deposit.
  TextColumn get note => text().nullable()();

  /// Source of the deposit: `manual`, `linked_account`, `salary`, `bonus`, `other`.
  TextColumn get source => text().nullable()();

  /// When the deposit was made.
  DateTimeColumn get depositDate => dateTime()();

  /// FK to [SavingTable] — optional link to a savings account.
  TextColumn get linkedAccountId => text().nullable()();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  @override
  List<Set<Column>> get uniqueKeys => [];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'planId': planId.name,
    'amount': amount.name,
    'note': note.name,
    'source': source.name,
    'depositDate': depositDate.name,
    'linkedAccountId': linkedAccountId.name,
  };
}
