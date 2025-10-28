import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_detail_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_task_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_expense_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_detail_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_task_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/expense_repository.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_group_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/impl/group_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/impl/reference_repository.dart';
import 'package:wise_spends/data/repositories/money_storage_repository.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/saving/impl/money_storage_repository.dart';
import 'package:wise_spends/data/repositories/saving/impl/saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/data/repositories/transaction/impl/transaction_repository.dart';

class RepositoryLocator extends IRepositoryLocator {
  @override
  List<ICrudRepository> retrieveAllRepository() {
    List<ICrudRepository> allRepository = [
      getUserRepository(),
      getGroupReferenceRepository(),
      getReferenceRepository(),
      getMoneyStorageRepository(),
      getSavingRepository(),
      getTransactionRepository(),
      getExpenseRepository(),
      getCommitmentRepository(),
      getCommitmentDetailRepository(),
      getCommitmentTaskRepository(),
    ];

    return allRepository;
  }

  @override
  IGroupReferenceRepository getGroupReferenceRepository() {
    IGroupReferenceRepository? repository =
        SingletonUtil.getSingleton<IGroupReferenceRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IGroupReferenceRepository>(
          GroupReferenceRepository());
    }

    return SingletonUtil.getSingleton<IGroupReferenceRepository>()!;
  }

  @override
  IMoneyStorageRepository getMoneyStorageRepository() {
    IMoneyStorageRepository? repository =
        SingletonUtil.getSingleton<IMoneyStorageRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IMoneyStorageRepository>(
          MoneyStorageRepository());
    }

    return SingletonUtil.getSingleton<IMoneyStorageRepository>()!;
  }

  @override
  IReferenceRepository getReferenceRepository() {
    IReferenceRepository? repository =
        SingletonUtil.getSingleton<IReferenceRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IReferenceRepository>(
          ReferenceRepository());
    }

    return SingletonUtil.getSingleton<IReferenceRepository>()!;
  }

  @override
  ISavingRepository getSavingRepository() {
    ISavingRepository? repository =
        SingletonUtil.getSingleton<ISavingRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ISavingRepository>(SavingRepository());
    }

    return SingletonUtil.getSingleton<ISavingRepository>()!;
  }

  @override
  ITransactionRepository getTransactionRepository() {
    ITransactionRepository? repository =
        SingletonUtil.getSingleton<ITransactionRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ITransactionRepository>(
          TransactionRepository());
    }

    return SingletonUtil.getSingleton<ITransactionRepository>()!;
  }

  @override
  IUserRepository getUserRepository() {
    IUserRepository? repository = SingletonUtil.getSingleton<IUserRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IUserRepository>(UserRepository());
    }

    return SingletonUtil.getSingleton<IUserRepository>()!;
  }

  @override
  ICommitmentDetailRepository getCommitmentDetailRepository() {
    ICommitmentDetailRepository? repository =
        SingletonUtil.getSingleton<ICommitmentDetailRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ICommitmentDetailRepository>(
          CommitmentDetailRepository());
    }

    return SingletonUtil.getSingleton<ICommitmentDetailRepository>()!;
  }

  @override
  ICommitmentRepository getCommitmentRepository() {
    ICommitmentRepository? repository =
        SingletonUtil.getSingleton<ICommitmentRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ICommitmentRepository>(
          CommitmentRepository());
    }

    return SingletonUtil.getSingleton<ICommitmentRepository>()!;
  }

  @override
  IExpenseRepository getExpenseRepository() {
    IExpenseRepository? repository =
        SingletonUtil.getSingleton<IExpenseRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IExpenseRepository>(ExpenseRepository());
    }

    return SingletonUtil.getSingleton<IExpenseRepository>()!;
  }

  @override
  ICommitmentTaskRepository getCommitmentTaskRepository() {
    ICommitmentTaskRepository? repository =
        SingletonUtil.getSingleton<ICommitmentTaskRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ICommitmentTaskRepository>(
          CommitmentTaskRepository());
    }

    return SingletonUtil.getSingleton<ICommitmentTaskRepository>()!;
  }
}
