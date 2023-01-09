import 'package:wise_spends/com/ainal/wise/spends/manager/i_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/transaction_manager.dart';

abstract class ITransactionManager extends IManager {
  factory ITransactionManager() {
    return TransactionManager();
  }

  Future<void> loadAsync(String token);
  Future<void> saveAsync(String token);
  void test(bool isError);
}
