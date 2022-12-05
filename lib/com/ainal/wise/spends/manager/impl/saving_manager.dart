import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_saving_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/impl/saving_service.dart';

class SavingManager extends ISavingManager {
  final ISavingService _savingService = SavingService();
  final IStartupManager _startupManager = StartupManager();

  @override
  Future<List<SavingWithTransactions>> loadSavingWithTransactionsAsync() async {
    Stream<List<SavingWithTransactions>> streamSavingWithTransactionsList =
        _savingService
            .watchAllSavingWithTransactions(_startupManager.currentUser.id);
    return await streamSavingWithTransactionsList.first;
  }
}
