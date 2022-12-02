import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_manager.dart';

abstract class ISavingManager extends IManager {
  Future<List<SavingWithTransactions>> loadSavingWithManagersAsync();
}
