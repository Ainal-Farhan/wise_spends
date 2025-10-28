import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/services/local/common/i_user_service.dart';
import 'package:wise_spends/data/services/local/common/impl/user_service.dart';
import 'package:wise_spends/data/services/local/masterdata/i_group_reference_service.dart';
import 'package:wise_spends/data/services/local/masterdata/i_reference_service.dart';
import 'package:wise_spends/data/services/local/masterdata/impl/group_reference_service.dart';
import 'package:wise_spends/data/services/local/masterdata/impl/reference_service.dart';
import 'package:wise_spends/data/services/local/saving/i_money_storage_service.dart';
import 'package:wise_spends/data/services/local/saving/i_saving_service.dart';
import 'package:wise_spends/data/services/local/saving/impl/money_storage_service.dart';
import 'package:wise_spends/data/services/local/saving/impl/saving_service.dart';
import 'package:wise_spends/data/services/local/transaction/i_transaction_service.dart';
import 'package:wise_spends/data/services/local/transaction/impl/transaction_service.dart';

class ServiceLocator extends IServiceLocator {
  @override
  IGroupReferenceService getGroupReferenceService() {
    IGroupReferenceService? service =
        SingletonUtil.getSingleton<IGroupReferenceService>();

    if (service == null) {
      SingletonUtil.registerSingleton<IGroupReferenceService>(
          GroupReferenceService());
    }

    return SingletonUtil.getSingleton<IGroupReferenceService>()!;
  }

  @override
  IMoneyStorageService getMoneyStorageService() {
    IMoneyStorageService? service =
        SingletonUtil.getSingleton<IMoneyStorageService>();

    if (service == null) {
      SingletonUtil.registerSingleton<IMoneyStorageService>(
          MoneyStorageService());
    }

    return SingletonUtil.getSingleton<IMoneyStorageService>()!;
  }

  @override
  IReferenceService getReferenceService() {
    IReferenceService? service =
        SingletonUtil.getSingleton<IReferenceService>();

    if (service == null) {
      SingletonUtil.registerSingleton<IReferenceService>(ReferenceService());
    }

    return SingletonUtil.getSingleton<IReferenceService>()!;
  }

  @override
  ISavingService getSavingService() {
    ISavingService? service = SingletonUtil.getSingleton<ISavingService>();

    if (service == null) {
      SingletonUtil.registerSingleton<ISavingService>(SavingService());
    }

    return SingletonUtil.getSingleton<ISavingService>()!;
  }

  @override
  ITransactionService getTransactionService() {
    ITransactionService? service =
        SingletonUtil.getSingleton<ITransactionService>();

    if (service == null) {
      SingletonUtil.registerSingleton<ITransactionService>(
          TransactionService());
    }

    return SingletonUtil.getSingleton<ITransactionService>()!;
  }

  @override
  IUserService getUserService() {
    IUserService? service = SingletonUtil.getSingleton<IUserService>();

    if (service == null) {
      SingletonUtil.registerSingleton<IUserService>(UserService());
    }

    return SingletonUtil.getSingleton<IUserService>()!;
  }
}
