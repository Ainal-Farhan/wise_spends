import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/service/local/common/i_user_service.dart';
import 'package:wise_spends/service/local/common/impl/user_service.dart';
import 'package:wise_spends/service/local/masterdata/i_group_reference_service.dart';
import 'package:wise_spends/service/local/masterdata/i_reference_service.dart';
import 'package:wise_spends/service/local/masterdata/impl/group_reference_service.dart';
import 'package:wise_spends/service/local/masterdata/impl/reference_service.dart';
import 'package:wise_spends/service/local/saving/i_money_storage_service.dart';
import 'package:wise_spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/service/local/saving/impl/money_storage_service.dart';
import 'package:wise_spends/service/local/saving/impl/saving_service.dart';
import 'package:wise_spends/service/local/transaction/i_transaction_service.dart';
import 'package:wise_spends/service/local/transaction/impl/transaction_service.dart';
import 'package:wise_spends/util/singleton_util.dart';

class ServiceLocator extends IServiceLocator {
  @override
  IGroupReferenceService getGroupReferenceService() {
    IGroupReferenceService? service =
        SingletonUtil.getSingleton<IGroupReferenceService>();

    if (service == null) {
      SingletonUtil.registerSingleton(GroupReferenceService());
    }

    return SingletonUtil.getSingleton<IGroupReferenceService>()!;
  }

  @override
  IMoneyStorageService getMoneyStorageService() {
    IMoneyStorageService? service =
        SingletonUtil.getSingleton<IMoneyStorageService>();

    if (service == null) {
      SingletonUtil.registerSingleton(MoneyStorageService());
    }

    return SingletonUtil.getSingleton<IMoneyStorageService>()!;
  }

  @override
  IReferenceService getReferenceService() {
    IReferenceService? service =
        SingletonUtil.getSingleton<IReferenceService>();

    if (service == null) {
      SingletonUtil.registerSingleton(ReferenceService());
    }

    return SingletonUtil.getSingleton<IReferenceService>()!;
  }

  @override
  ISavingService getSavingService() {
    ISavingService? service = SingletonUtil.getSingleton<ISavingService>();

    if (service == null) {
      SingletonUtil.registerSingleton(SavingService());
    }

    return SingletonUtil.getSingleton<ISavingService>()!;
  }

  @override
  ITransactionService getTransactionService() {
    ITransactionService? service =
        SingletonUtil.getSingleton<ITransactionService>();

    if (service == null) {
      SingletonUtil.registerSingleton(TransactionService());
    }

    return SingletonUtil.getSingleton<ITransactionService>()!;
  }

  @override
  IUserService getUserService() {
    IUserService? service = SingletonUtil.getSingleton<IUserService>();

    if (service == null) {
      SingletonUtil.registerSingleton(UserService());
    }

    return SingletonUtil.getSingleton<IUserService>()!;
  }
}
