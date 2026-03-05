import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';
import 'package:wise_spends/data/db/domain/transaction/recurring_transaction_table.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_tag_table.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_tag_map_table.dart';

export './transaction_table.dart';
export './recurring_transaction_table.dart';
export './transaction_tag_table.dart';
export './transaction_tag_map_table.dart';

abstract class Transaction {
  static const List<dynamic> tableList = [
    TransactionTable,
    RecurringTransactionTable,
    TransactionTagTable,
    TransactionTagMapTable,
  ];
}
