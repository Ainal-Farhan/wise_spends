import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_task_table.dart';
import 'package:wise_spends/data/db/domain/expense/payee_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/db/domain/transaction/category_table.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

@DataClassName("${DomainTableConstant.transactionTablePrefix}Transaction")
class TransactionTable extends BaseEntityTable {
  // -- Core ------------------------------------------------------------------

  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get description => text().withDefault(const Constant(''))();

  /// Always positive — direction is determined by [type].
  RealColumn get amount =>
      real().customConstraint('CHECK (amount > 0) NOT NULL')();

  // -- Account links ---------------------------------------------------------

  /// Source savings account — where money comes FROM.
  /// For income: account receiving money.
  /// For expense: account being debited.
  /// For transfer/commitment: the source account.
  TextColumn get savingId => text().references(SavingTable, #id)();

  /// Destination savings account — where money goes TO.
  /// Only set for transfer and commitment transactions. Null otherwise.
  TextColumn get destinationSavingId =>
      text().nullable().references(SavingTable, #id)();

  // -- Category link ---------------------------------------------------------

  /// FK to [CategoryTable].
  /// Null for transfer and commitment transactions.
  TextColumn get categoryId =>
      text().nullable().references(CategoryTable, #id)();

  // -- Commitment task link --------------------------------------------------

  /// FK to [CommitmentTaskTable] — set when this transaction was created
  /// by completing a commitment task.
  TextColumn get commitmentTaskId =>
      text().nullable().references(CommitmentTaskTable, #id)();

  // -- Payee link ------------------------------------------------------------

  /// FK to [PayeeTable] — only set for third-party payment transactions.
  TextColumn get payeeId => text().nullable().references(PayeeTable, #id)();

  // -- Metadata --------------------------------------------------------------

  DateTimeColumn get transactionDateTime => dateTime().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'type': type.name,
    'description': description.name,
    'amount': amount.name,
    'savingId': savingId.name,
    'destinationSavingId': destinationSavingId.name,
    'categoryId': categoryId.name,
    'commitmentTaskId': commitmentTaskId.name,
    'payeeId': payeeId.name,
    'transactionDateTime': transactionDateTime.name,
    'note': note.name,
  };
}
