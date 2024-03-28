import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/repository/common/i_user.repository.dart';
import 'package:wise_spends/repository/common/impl/user_repository.dart';
import 'package:wise_spends/repository/masterdata/i_group_reference_repository.dart';
import 'package:wise_spends/repository/masterdata/i_reference_repository.dart';
import 'package:wise_spends/repository/masterdata/impl/group_reference_repository.dart';
import 'package:wise_spends/repository/masterdata/impl/reference_repository.dart';
import 'package:wise_spends/repository/saving/i_money_storage_repository.dart';
import 'package:wise_spends/repository/saving/i_saving_repository.dart';
import 'package:wise_spends/repository/saving/impl/money_storage_repository.dart';
import 'package:wise_spends/repository/saving/impl/saving_repository.dart';
import 'package:wise_spends/repository/transaction/i_transaction_repository.dart';
import 'package:wise_spends/repository/transaction/impl/transaction_repository.dart';
import 'package:wise_spends/util/singleton_util.dart';

class RepositoryLocator extends IRepositoryLocator {
  @override
  IGroupReferenceRepository getGroupReferenceRepository() {
    return SingletonUtil.getSingleton<IGroupReferenceRepository>();
  }

  @override
  IMoneyStorageRepository getMoneyStorageRepository() {
    return SingletonUtil.getSingleton<IMoneyStorageRepository>();
  }

  @override
  IReferenceRepository getReferenceRepository() {
    return SingletonUtil.getSingleton<IReferenceRepository>();
  }

  @override
  ISavingRepository getSavingRepository() {
    return SingletonUtil.getSingleton<ISavingRepository>();
  }

  @override
  ITransactionRepository getTransactionRepository() {
    return SingletonUtil.getSingleton<ITransactionRepository>();
  }

  @override
  IUserRepository getUserRepository() {
    return SingletonUtil.getSingleton<IUserRepository>();
  }

  @override
  void registerLocator() {
    SingletonUtil.registerSingleton<IUserRepository>(UserRepository());
    SingletonUtil.registerSingleton<IGroupReferenceRepository>(
        GroupReferenceRepository());
    SingletonUtil.registerSingleton<IReferenceRepository>(
        ReferenceRepository());
    SingletonUtil.registerSingleton<IMoneyStorageRepository>(
        MoneyStorageRepository());
    SingletonUtil.registerSingleton<ISavingRepository>(SavingRepository());
    SingletonUtil.registerSingleton<ITransactionRepository>(
        TransactionRepository());
  }
}
