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
    return SingletonUtil.getSingleton<IGroupReferenceService>();
  }

  @override
  IMoneyStorageService getMoneyStorageService() {
    return SingletonUtil.getSingleton<IMoneyStorageService>();
  }

  @override
  IReferenceService getReferenceService() {
    return SingletonUtil.getSingleton<IReferenceService>();
  }

  @override
  ISavingService getSavingService() {
    return SingletonUtil.getSingleton<ISavingService>();
  }

  @override
  ITransactionService getTransactionService() {
    return SingletonUtil.getSingleton<ITransactionService>();
  }

  @override
  IUserService getUserService() {
    return SingletonUtil.getSingleton<IUserService>();
  }

  @override
  void registerLocator() {
    SingletonUtil.registerSingleton<IUserService>(UserService());
    SingletonUtil.registerSingleton<IGroupReferenceService>(
        GroupReferenceService());
    SingletonUtil.registerSingleton<IReferenceService>(ReferenceService());
    SingletonUtil.registerSingleton<IMoneyStorageService>(
        MoneyStorageService());
    SingletonUtil.registerSingleton<ISavingService>(SavingService());
    SingletonUtil.registerSingleton<ITransactionService>(TransactionService());
  }
}
