import 'package:drift/drift.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/constant/saving/saving_constant.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/composite/saving_with_transactions.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/service/local/saving/i_money_storage_service.dart';
import 'package:wise_spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/service/local/transaction/i_transaction_service.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';
import 'package:wise_spends/vo/impl/saving/edit_saving_form_vo.dart';
import 'package:wise_spends/vo/impl/money_storage/money_storage_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class SavingManager extends ISavingManager {
  final ISavingService _savingService =
      SingletonUtil.getSingleton<IServiceLocator>()!.getSavingService();
  final ITransactionService _transactionService =
      SingletonUtil.getSingleton<IServiceLocator>()!.getTransactionService();
  final IMoneyStorageService _moneyStorageService =
      SingletonUtil.getSingleton<IServiceLocator>()!.getMoneyStorageService();
  final IStartupManager _startupManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getStartupManager();

  @override
  Future<List<SavingWithTransactions>> loadSavingWithTransactionsAsync() async {
    Stream<List<SavingWithTransactions>> streamSavingWithTransactionsList =
        _savingService
            .watchAllSavingWithTransactions(_startupManager.currentUser.id);
    return await streamSavingWithTransactionsList.first;
  }

  @override
  Future<SvngSaving> addNewSaving({
    required String name,
    required double initialAmount,
    required bool isHasGoal,
    required double goalAmount,
    required String moneyStorageId,
    required SavingTableType savingTableType,
  }) async {
    SavingTableCompanion savingTableCompanion = SavingTableCompanion.insert(
        createdBy: _startupManager.currentUser.name,
        lastModifiedBy: _startupManager.currentUser.name,
        dateUpdated: DateTime.now(),
        name: Value(name),
        userId: Value(_startupManager.currentUser.id),
        currentAmount: Value(initialAmount),
        isHasGoal: Value(isHasGoal),
        goal: Value(goalAmount),
        moneyStorageId: Value(moneyStorageId),
        type: savingTableType.value);

    return await _savingService.add(savingTableCompanion);
  }

  @override
  Future<bool> deleteSelectedSaving(String id) async {
    try {
      // get saving
      SvngSaving? saving = await _savingService.watchSavingById(id).first;

      if (saving != null) {
        // delete all transactions based on savingId
        await _transactionService.deleteAllBasedOnSavingId(saving.id);

        // delete saving
        await _savingService.delete(saving);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<SvngSaving?> getSavingById(String savingId) async {
    return await _savingService.watchSavingById(savingId).first;
  }

  @override
  Future<void> updateSavingCurrentAmount({
    required String savingId,
    required String transactionType,
    required double transactionAmount,
  }) async {
    SvngSaving? currentSaving =
        await _savingService.watchSavingById(savingId).first;

    if (currentSaving != null) {
      double currentAmount = currentSaving.currentAmount;

      switch (transactionType) {
        case SavingConstant.savingTransactionIn:
          currentAmount += transactionAmount;
          break;
        case SavingConstant.savingTransactionOut:
          currentAmount -= transactionAmount;
      }
      SavingTableCompanion updatedSaving = SavingTableCompanion.insert(
          createdBy: _startupManager.currentUser.name,
          lastModifiedBy: _startupManager.currentUser.name,
          id: Value(savingId),
          dateUpdated: DateTime.now(),
          currentAmount: Value(currentAmount),
          type: currentSaving.type);

      await _savingService.updatePart(updatedSaving);
    }
  }

  @override
  Future<void> updateSaving({
    required EditSavingFormVO editSavingFormVO,
  }) async {
    SavingTableCompanion updatedSaving = SavingTableCompanion(
      id: Value(editSavingFormVO.savingId),
      name: Value(editSavingFormVO.savingName),
      currentAmount: Value(editSavingFormVO.currentAmount),
      isHasGoal: Value(editSavingFormVO.isHasGoal),
      goal: Value(
        editSavingFormVO.isHasGoal ? editSavingFormVO.goalAmount : .0,
      ),
      moneyStorageId: Value(editSavingFormVO.moneyStorageId),
      dateUpdated: Value(DateTime.now()),
    );

    await _savingService.updatePart(updatedSaving);
  }

  @override
  Future<List<DropDownValueModel>>
      getCurrentUserMoneyStorageDropDownValueModelList() async {
    String currentUser = _startupManager.currentUser.id;
    List<DropDownValueModel> moneyStorageDropDownValueModelList = [];
    Stream<List<SvngMoneyStorage>> streamMoneyStorageList =
        _moneyStorageService.watchMoneyStorageListByUserId(currentUser);

    for (SvngMoneyStorage moneyStorage in await streamMoneyStorageList.first) {
      moneyStorageDropDownValueModelList.add(DropDownValueModel(
        name: '${moneyStorage.shortName} - ${moneyStorage.longName}',
        value: moneyStorage.id,
      ));
    }

    return moneyStorageDropDownValueModelList;
  }

  @override
  Future<List<SvngMoneyStorage>> getCurrentUserMoneyStorageList() async {
    String currentUserId = _startupManager.currentUser.id;

    return await _moneyStorageService
        .watchMoneyStorageListByUserId(currentUserId)
        .first;
  }

  @override
  Future<bool> deleteSelectedMoneyStorage(String id) async {
    try {
      // get money storage
      SvngMoneyStorage? moneyStorage =
          await SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getMoneyStorageRepository()
              .findById(id: id);

      if (moneyStorage != null) {
        // delete saving
        await _moneyStorageService.delete(moneyStorage);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<MoneyStorageVO>> getCurrentUserMoneyStorageVOList() async {
    List<MoneyStorageVO> moneyStorageVOList = [];
    for (SvngMoneyStorage moneyStorage in (await _moneyStorageService
        .watchMoneyStorageListByUserId(_startupManager.currentUser.id)
        .first)) {
      double amount = (await _savingService
              .watchAllSavingBasedOnMoneyStorageId(moneyStorage.id)
              .first)
          .fold(
              0,
              (previousValue, SvngSaving saving) =>
                  previousValue + saving.currentAmount);

      moneyStorageVOList.add(MoneyStorageVO(
        moneyStorage: moneyStorage,
        amount: amount,
      ));
    }

    return moneyStorageVOList;
  }

  @override
  Future<SvngMoneyStorage> addNewMoneyStorage({
    required String shortName,
    required String longName,
    required String type,
  }) async {
    MoneyStorageTableCompanion moneyStorageTableCompanion =
        MoneyStorageTableCompanion.insert(
      createdBy: _startupManager.currentUser.name,
      lastModifiedBy: _startupManager.currentUser.name,
      dateUpdated: DateTime.now(),
      longName: longName,
      shortName: shortName,
      type: type,
      dateCreated: Value(DateTime.now()),
      userId: Value(_startupManager.currentUser.id),
    );

    return await _moneyStorageService.add(moneyStorageTableCompanion);
  }

  @override
  Future<void> updateMoneyStorage({
    required EditMoneyStorageFormVO editMoneyStorageFormVO,
  }) async {
    MoneyStorageTableCompanion updatedMoneyStorage = MoneyStorageTableCompanion(
      id: Value(editMoneyStorageFormVO.id ?? ''),
      shortName: Value(editMoneyStorageFormVO.shortName ?? ''),
      longName: Value(editMoneyStorageFormVO.longName ?? ''),
      type: Value(editMoneyStorageFormVO.type ?? ''),
      dateUpdated: Value(DateTime.now()),
    );

    await _moneyStorageService.updatePart(updatedMoneyStorage);
  }

  @override
  Future<List<ListSavingVO>> loadListSavingVOList() async {
    return (await _savingService
            .watchAllSavingWithMoneyStorageBasedOnUserId(
                _startupManager.currentUser.id)
            .first)
        .map((savingWithMoneyStorage) => ListSavingVO(
            saving: savingWithMoneyStorage.saving,
            moneyStorage: savingWithMoneyStorage.moneyStorage))
        .toList();
  }
}
