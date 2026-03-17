import 'package:drift/drift.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_table.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_detail_table.dart';
import 'package:wise_spends/data/db/domain/expense/payee_table.dart';

// ---------------------------------------------------------------------------
// Commitment Task Table
// ---------------------------------------------------------------------------

@DataClassName("${DomainTableConstant.expenseTablePrefix}CommitmentTask")
class CommitmentTaskTable extends BaseEntityTable {
  // -- Basic info ------------------------------------------------------------

  TextColumn get name => text()();

  /// Always positive. Direction is implied by [type]:
  ///   internalTransfer  → deducted from sourceSavingId, added to targetSavingId
  ///   thirdPartyPayment → deducted from sourceSavingId, sent out
  ///   cash              → no digital account affected
  RealColumn get amount => real()();

  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  // -- Commitment hierarchy --------------------------------------------------

  TextColumn get commitmentId => text().references(CommitmentTable, #id)();

  /// Non-nullable: every task must belong to a specific detail.
  /// Previously nullable, which allowed orphaned tasks with no detail link.
  TextColumn get commitmentDetailId =>
      text().references(CommitmentDetailTable, #id)();

  // -- Payment type ----------------------------------------------------------

  /// Replaces the brittle `isThirdParty` bool. Adding new payment types only
  /// requires a new enum value — no extra columns, no migrations.
  IntColumn get type => intEnum<CommitmentTaskType>()();

  // -- Source saving ---------------------------------------------------------

  /// The saving account funds are drawn from. Nullable for cash payments where
  /// no digital account is debited.
  TextColumn get sourceSavingId =>
      text().nullable().references(SavingTable, #id)();

  // -- Internal transfer target ----------------------------------------------

  /// Only populated when type == CommitmentTaskType.internalTransfer.
  TextColumn get targetSavingId =>
      text().nullable().references(SavingTable, #id)();

  // -- Third-party payee -----------------------------------------------------

  /// Only populated when type == CommitmentTaskType.thirdPartyPayment.
  /// References PayeeTable so recipient details are stored once and reused.
  TextColumn get payeeId => text().nullable().references(PayeeTable, #id)();

  // -- Payment metadata ------------------------------------------------------

  /// Free-text note for this specific task (distinct from payee-level note).
  TextColumn get note => text().nullable()();

  /// Reference number from the completed transaction (e.g. FPX ref, receipt no).
  /// Only meaningful once isDone == true.
  TextColumn get paymentReference => text().nullable()();

  /// Foreign key to a Transaction record created when this task is marked done.
  /// Null until the task is completed.
  TextColumn get transactionId => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'name': name.name,
    'amount': amount.name,
    'isDone': isDone.name,
    'commitmentId': commitmentId.name,
    'commitmentDetailId': commitmentDetailId.name,
    'type': type.name,
    'sourceSavingId': sourceSavingId.name,
    'targetSavingId': targetSavingId.name,
    'payeeId': payeeId.name,
    'note': note.name,
    'paymentReference': paymentReference.name,
    'transactionId': transactionId.name,
  };
}
