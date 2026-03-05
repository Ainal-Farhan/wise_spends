export './user_table.dart';
export './exchange_rate_table.dart';

import 'package:wise_spends/data/db/domain/common/user_table.dart';
import 'package:wise_spends/data/db/domain/common/exchange_rate_table.dart';

abstract class Common {
  static const List<dynamic> tableList = [
    UserTable,
    ExchangeRateTable,
  ];
}
