import 'package:wise_spends/data/db/domain/saving/money_storage_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';

export './saving_table.dart';
export './money_storage_table.dart';

abstract class Saving {
  static const List<dynamic> tableList = [SavingTable, MoneyStorageTable];
}
