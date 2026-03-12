import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/db/domain/expense/payee_table.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_detail_type.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';

// ---------------------------------------------------------------------------
// CommitmentDetail Table
// ---------------------------------------------------------------------------
@DataClassName("${DomainTableConstant.expenseTablePrefix}CommitmentDetail")
class CommitmentDetailTable extends BaseEntityTable {
  // -- Core fields -----------------------------------------------------------

  RealColumn get amount => real()();
  TextColumn get description => text()();

  /// Recurrence pattern (monthly, weekly, etc.). Kept for scheduling logic.
  IntColumn get type => intEnum<CommitmentDetailType>()();

  // -- Payment type ----------------------------------------------------------

  /// Determines HOW this detail's tasks are paid when distributed:
  ///   internalTransfer  → sourceSaving (savingId) → targetSaving (targetSavingId)
  ///   thirdPartyPayment → sourceSaving (savingId) → external payee (payeeId)
  ///   cash              → no digital account movement
  ///
  /// Defaults to internalTransfer (index 0) so existing rows stay valid.
  IntColumn get taskType =>
      intEnum<CommitmentTaskType>().withDefault(const Constant(0))();

  // -- Source saving ---------------------------------------------------------

  /// The savings account funds are drawn FROM. Required for internalTransfer
  /// and thirdPartyPayment; nullable for cash.
  TextColumn get savingId => text().nullable().references(SavingTable, #id)();

  // -- Internal transfer target ----------------------------------------------

  /// Destination account. Only meaningful when taskType == internalTransfer.
  TextColumn get targetSavingId =>
      text().nullable().references(SavingTable, #id)();

  // -- Third-party payee -----------------------------------------------------

  /// Recipient. Only meaningful when taskType == thirdPartyPayment.
  TextColumn get payeeId => text().nullable().references(PayeeTable, #id)();

  // -- Commitment parent -----------------------------------------------------

  TextColumn get commitmentId => text().references(CommitmentTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'amount': amount.name,
    'description': description.name,
    'type': type.name,
    'taskType': taskType.name,
    'savingId': savingId.name,
    'targetSavingId': targetSavingId.name,
    'payeeId': payeeId.name,
    'commitmentId': commitmentId.name,
  };
}
