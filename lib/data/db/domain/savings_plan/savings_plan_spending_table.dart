import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_item_table.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';

/// Savings Plan Spending table for tracking money spent from a savings plan.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// Each spending entry reduces the available funds in the plan.
/// Optionally links to a [TransactionTable] for detailed tracking.
/// Optionally links to a [SavingsPlanItemTable] for item-level tracking.
@DataClassName("${DomainTableConstant.savingsPlanTablePrefix}Spending")
class SavingsPlanSpendingTable extends BaseEntityTable {
  /// FK to [SavingsPlanTable] — the plan this spending belongs to.
  TextColumn get planId => text().references(SavingsPlanTable, #id)();

  /// FK to [SavingsPlanItemTable] — optional link to a specific budget item.
  TextColumn get itemId => text().nullable().references(SavingsPlanItemTable, #id)();

  /// FK to [TransactionTable] — optional link to the actual transaction.
  TextColumn get transactionId => text().nullable().references(TransactionTable, #id)();

  /// Spending amount (always positive).
  RealColumn get amount => real()();

  /// Description of the spending.
  TextColumn get description => text().nullable()();

  /// Vendor/payee name where money was spent.
  TextColumn get vendor => text().nullable()();

  /// Optional path to receipt image.
  TextColumn get receiptImagePath => text().nullable()();

  /// When the spending occurred.
  DateTimeColumn get spendingDate => dateTime()();

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
    'itemId': itemId.name,
    'transactionId': transactionId.name,
    'amount': amount.name,
    'description': description.name,
    'vendor': vendor.name,
    'receiptImagePath': receiptImagePath.name,
    'spendingDate': spendingDate.name,
  };
}
