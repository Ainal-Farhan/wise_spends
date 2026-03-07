import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_detail_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_task_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_expense_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_payee_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_detail_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_task_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/expense_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/payee_repository.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_group_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/impl/group_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/impl/reference_repository.dart';
import 'package:wise_spends/data/repositories/saving/i_money_storage_repository.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/saving/impl/money_storage_repository.dart';
import 'package:wise_spends/data/repositories/saving/impl/saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/data/repositories/transaction/impl/transaction_repository.dart';
import 'package:wise_spends/data/repositories/category/impl/category_repository.dart';
import 'package:wise_spends/data/repositories/budget/impl/budget_repository.dart';
import 'package:wise_spends/data/repositories/budget_plan/impl/budget_plan_repository.dart';
import 'package:wise_spends/data/repositories/category/i_category_repository.dart';
import 'package:wise_spends/data/repositories/budget/i_budget_repository.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_deposit_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_spending_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_milestone_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_linked_account_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/impl/savings_plan_deposit_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/impl/savings_plan_spending_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/impl/savings_plan_milestone_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/impl/savings_plan_linked_account_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_tag_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_tag_map_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_recurring_transaction_repository.dart';
import 'package:wise_spends/data/repositories/transaction/impl/transaction_tag_repository.dart';
import 'package:wise_spends/data/repositories/transaction/impl/transaction_tag_map_repository.dart';
import 'package:wise_spends/data/repositories/transaction/impl/recurring_transaction_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_reference_data_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_expense_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/impl/reference_data_repository.dart';
import 'package:wise_spends/data/repositories/expense/impl/expense_reference_repository.dart';

class RepositoryLocator extends IRepositoryLocator {
  @override
  List<ICrudRepository> retrieveAllRepository() {
    List<ICrudRepository> allRepository = [
      getUserRepository(),
      getGroupReferenceRepository(),
      getReferenceRepository(),
      getReferenceDataRepository(),
      getMoneyStorageRepository(),
      getSavingRepository(),
      getTransactionRepository(),
      getTransactionTagRepository(),
      getTransactionTagMapRepository(),
      getRecurringTransactionRepository(),
      getExpenseRepository(),
      getExpenseReferenceRepository(),
      getCommitmentRepository(),
      getCommitmentDetailRepository(),
      getCommitmentTaskRepository(),
      getPayeeRepository(),
      getCategoryRepository(),
      getBudgetRepository(),
      getBudgetPlanRepository(),
      getSavingsPlanDepositRepository(),
      getSavingsPlanSpendingRepository(),
      getSavingsPlanMilestoneRepository(),
      getSavingsPlanLinkedAccountRepository(),
    ];

    return allRepository;
  }

  @override
  IGroupReferenceRepository getGroupReferenceRepository() {
    IGroupReferenceRepository? repository =
        SingletonUtil.getSingleton<IGroupReferenceRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IGroupReferenceRepository>(
        GroupReferenceRepository(),
      );
    }

    return SingletonUtil.getSingleton<IGroupReferenceRepository>()!;
  }

  @override
  IMoneyStorageRepository getMoneyStorageRepository() {
    IMoneyStorageRepository? repository =
        SingletonUtil.getSingleton<IMoneyStorageRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IMoneyStorageRepository>(
        MoneyStorageRepository(),
      );
    }

    return SingletonUtil.getSingleton<IMoneyStorageRepository>()!;
  }

  @override
  IReferenceRepository getReferenceRepository() {
    IReferenceRepository? repository =
        SingletonUtil.getSingleton<IReferenceRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IReferenceRepository>(
        ReferenceRepository(),
      );
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
        TransactionRepository(),
      );
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
        CommitmentDetailRepository(),
      );
    }

    return SingletonUtil.getSingleton<ICommitmentDetailRepository>()!;
  }

  @override
  ICommitmentRepository getCommitmentRepository() {
    ICommitmentRepository? repository =
        SingletonUtil.getSingleton<ICommitmentRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ICommitmentRepository>(
        CommitmentRepository(),
      );
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
        CommitmentTaskRepository(),
      );
    }

    return SingletonUtil.getSingleton<ICommitmentTaskRepository>()!;
  }

  @override
  ICategoryRepository getCategoryRepository() {
    ICategoryRepository? repository =
        SingletonUtil.getSingleton<ICategoryRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ICategoryRepository>(
        CategoryRepository(),
      );
    }

    return SingletonUtil.getSingleton<ICategoryRepository>()!;
  }

  @override
  IBudgetRepository getBudgetRepository() {
    IBudgetRepository? repository =
        SingletonUtil.getSingleton<IBudgetRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IBudgetRepository>(BudgetRepository());
    }

    return SingletonUtil.getSingleton<IBudgetRepository>()!;
  }

  @override
  IBudgetPlanRepository getBudgetPlanRepository() {
    IBudgetPlanRepository? repository =
        SingletonUtil.getSingleton<IBudgetPlanRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IBudgetPlanRepository>(
        BudgetPlanRepository(),
      );
    }

    return SingletonUtil.getSingleton<IBudgetPlanRepository>()!;
  }

  @override
  IPayeeRepository getPayeeRepository() {
    IPayeeRepository? repository =
        SingletonUtil.getSingleton<IPayeeRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IPayeeRepository>(PayeeRepository());
    }

    return SingletonUtil.getSingleton<IPayeeRepository>()!;
  }

  @override
  ISavingsPlanDepositRepository getSavingsPlanDepositRepository() {
    ISavingsPlanDepositRepository? repository =
        SingletonUtil.getSingleton<ISavingsPlanDepositRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ISavingsPlanDepositRepository>(
        SavingsPlanDepositRepository(),
      );
    }

    return SingletonUtil.getSingleton<ISavingsPlanDepositRepository>()!;
  }

  @override
  ISavingsPlanSpendingRepository getSavingsPlanSpendingRepository() {
    ISavingsPlanSpendingRepository? repository =
        SingletonUtil.getSingleton<ISavingsPlanSpendingRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ISavingsPlanSpendingRepository>(
        SavingsPlanSpendingRepository(),
      );
    }

    return SingletonUtil.getSingleton<ISavingsPlanSpendingRepository>()!;
  }

  @override
  ISavingsPlanMilestoneRepository getSavingsPlanMilestoneRepository() {
    ISavingsPlanMilestoneRepository? repository =
        SingletonUtil.getSingleton<ISavingsPlanMilestoneRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ISavingsPlanMilestoneRepository>(
        SavingsPlanMilestoneRepository(),
      );
    }

    return SingletonUtil.getSingleton<ISavingsPlanMilestoneRepository>()!;
  }

  @override
  ISavingsPlanLinkedAccountRepository getSavingsPlanLinkedAccountRepository() {
    ISavingsPlanLinkedAccountRepository? repository =
        SingletonUtil.getSingleton<ISavingsPlanLinkedAccountRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ISavingsPlanLinkedAccountRepository>(
        SavingsPlanLinkedAccountRepository(),
      );
    }

    return SingletonUtil.getSingleton<ISavingsPlanLinkedAccountRepository>()!;
  }

  @override
  ITransactionTagRepository getTransactionTagRepository() {
    ITransactionTagRepository? repository =
        SingletonUtil.getSingleton<ITransactionTagRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ITransactionTagRepository>(
        TransactionTagRepository(),
      );
    }

    return SingletonUtil.getSingleton<ITransactionTagRepository>()!;
  }

  @override
  ITransactionTagMapRepository getTransactionTagMapRepository() {
    ITransactionTagMapRepository? repository =
        SingletonUtil.getSingleton<ITransactionTagMapRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<ITransactionTagMapRepository>(
        TransactionTagMapRepository(),
      );
    }

    return SingletonUtil.getSingleton<ITransactionTagMapRepository>()!;
  }

  @override
  IRecurringTransactionRepository getRecurringTransactionRepository() {
    IRecurringTransactionRepository? repository =
        SingletonUtil.getSingleton<IRecurringTransactionRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IRecurringTransactionRepository>(
        RecurringTransactionRepository(),
      );
    }

    return SingletonUtil.getSingleton<IRecurringTransactionRepository>()!;
  }

  @override
  IReferenceDataRepository getReferenceDataRepository() {
    IReferenceDataRepository? repository =
        SingletonUtil.getSingleton<IReferenceDataRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IReferenceDataRepository>(
        ReferenceDataRepository(),
      );
    }

    return SingletonUtil.getSingleton<IReferenceDataRepository>()!;
  }

  @override
  IExpenseReferenceRepository getExpenseReferenceRepository() {
    IExpenseReferenceRepository? repository =
        SingletonUtil.getSingleton<IExpenseReferenceRepository>();

    if (repository == null) {
      SingletonUtil.registerSingleton<IExpenseReferenceRepository>(
        ExpenseReferenceRepository(),
      );
    }

    return SingletonUtil.getSingleton<IExpenseReferenceRepository>()!;
  }
}
