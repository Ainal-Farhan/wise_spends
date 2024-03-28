export './transaction_table.dart';

import 'package:wise_spends/db/domain/transaction/transaction_table.dart';

abstract class Transaction {
  static const List<dynamic> tableList = [TransactionTable];
}
