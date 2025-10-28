import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';

export './transaction_table.dart';


abstract class Transaction {
  static const List<dynamic> tableList = [TransactionTable];
}
