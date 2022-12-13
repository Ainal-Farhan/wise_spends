import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/saving/impl/saving_service.dart';

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

  @override
  Future<void> addNewSaving({
    required String name,
  }) async {
    SavingTableCompanion savingTableCompanion = SavingTableCompanion.insert(
      dateUpdated: DateTime.now(),
      name: name,
      userId: _startupManager.currentUser.id,
    );

    return await _savingService.add(savingTableCompanion);
  }
}
