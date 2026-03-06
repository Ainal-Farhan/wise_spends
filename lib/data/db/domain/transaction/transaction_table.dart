import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/expense/expense_table.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_task_table.dart';
import 'package:wise_spends/data/db/domain/expense/payee_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

@DataClassName("${DomainTableConstant.transactionTablePrefix}Transaction")
class TransactionTable extends BaseEntityTable {
  // -- Core ------------------------------------------------------------------

  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get description => text().withDefault(const Constant(''))();

  /// Always positive — direction is determined by [type] and [transferType].
  RealColumn get amount =>
      real().customConstraint('CHECK (amount > 0) NOT NULL')();

  // -- Account links ---------------------------------------------------------

  /// The savings account this transaction belongs to.
  TextColumn get savingId => text().references(SavingTable, #id)();

  /// Linked expense record, if applicable.
  TextColumn get expenseId => text().nullable().references(ExpenseTable, #id)();

  // -- Commitment task link --------------------------------------------------

  /// FK to the [CommitmentTaskTable] row that triggered this transaction.
  ///
  /// Null for transactions not originating from a commitment task.
  /// Populated when [CommitmentManager.updateStatusCommitmentTask] completes
  /// a task and creates the corresponding transaction record.
  ///
  /// This allows:
  ///   - Tracing any transaction back to its source commitment task.
  ///   - Preventing duplicate transactions if complete is tapped twice.
  ///   - Displaying commitment context on the transaction detail screen.
  TextColumn get commitmentTaskId =>
      text().nullable().references(CommitmentTaskTable, #id)();

  // -- Payee link ------------------------------------------------------------

  /// FK to [PayeeTable] — only set for third-party payment transactions.
  ///
  /// Storing this on the transaction (not just on the task) means:
  ///   - The transaction history screen can show who was paid without
  ///     joining back to the task table.
  ///   - If the task is deleted later, the payee info is still on the record.
  TextColumn get payeeId => text().nullable().references(PayeeTable, #id)();

  // -- Transfer pairing ------------------------------------------------------

  /// Groups the two transaction rows of an internal transfer (debit + credit).
  /// Both rows share the same [transferGroupId] so they can be displayed
  /// as a single logical transfer in the UI and reversed together if needed.
  TextColumn get transferGroupId => text().nullable()();

  /// 'debit' | 'credit' — which side of the transfer this row represents.
  /// Only set when [transferGroupId] is non-null.
  TextColumn get transferType => text().nullable()();

  // -- Metadata --------------------------------------------------------------

  DateTimeColumn get transactionDateTime => dateTime().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'type': type.name,
    'description': description.name,
    'amount': amount.name,
    'savingId': savingId.name,
    'expenseId': expenseId.name,
    'commitmentTaskId': commitmentTaskId.name,
    'payeeId': payeeId.name,
    'transferGroupId': transferGroupId.name,
    'transferType': transferType.name,
    'transactionDateTime': transactionDateTime.name,
    'note': note.name,
  };
}
