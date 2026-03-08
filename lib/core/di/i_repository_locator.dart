import 'package:wise_spends/core/di/i_locator.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_detail_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_task_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_expense_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_payee_repository.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_group_reference_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_reference_repository.dart';
import 'package:wise_spends/data/repositories/saving/i_money_storage_repository.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/data/repositories/category/i_category_repository.dart';
import 'package:wise_spends/data/repositories/budget/i_budget_repository.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_deposit_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_spending_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_milestone_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_linked_account_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_item_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_item_tag_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_tag_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_tag_map_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_recurring_transaction_repository.dart';
import 'package:wise_spends/data/repositories/masterdata/i_reference_data_repository.dart';
import 'package:wise_spends/data/repositories/expense/i_expense_reference_repository.dart';

abstract class IRepositoryLocator extends ILocator {
  List<ICrudRepository> retrieveAllRepository();

  IUserRepository getUserRepository();
  IGroupReferenceRepository getGroupReferenceRepository();
  IReferenceRepository getReferenceRepository();
  IMoneyStorageRepository getMoneyStorageRepository();
  ISavingRepository getSavingRepository();
  ITransactionRepository getTransactionRepository();
  IExpenseRepository getExpenseRepository();
  ICommitmentRepository getCommitmentRepository();
  ICommitmentDetailRepository getCommitmentDetailRepository();
  ICommitmentTaskRepository getCommitmentTaskRepository();
  IPayeeRepository getPayeeRepository();

  // Category Repository
  ICategoryRepository getCategoryRepository();

  // Budget Repository
  IBudgetRepository getBudgetRepository();

  // Budget Plan Repository
  IBudgetPlanRepository getBudgetPlanRepository();

  // Savings Plan Child Repositories
  ISavingsPlanDepositRepository getSavingsPlanDepositRepository();
  ISavingsPlanSpendingRepository getSavingsPlanSpendingRepository();
  ISavingsPlanMilestoneRepository getSavingsPlanMilestoneRepository();
  ISavingsPlanLinkedAccountRepository getSavingsPlanLinkedAccountRepository();
  ISavingsPlanItemRepository getSavingsPlanItemRepository();
  ISavingsPlanItemTagRepository getSavingsPlanItemTagRepository();

  // Transaction Child Repositories
  ITransactionTagRepository getTransactionTagRepository();
  ITransactionTagMapRepository getTransactionTagMapRepository();
  IRecurringTransactionRepository getRecurringTransactionRepository();

  // MasterData Child Repositories
  IReferenceDataRepository getReferenceDataRepository();

  // Expense Reference Repository
  IExpenseReferenceRepository getExpenseReferenceRepository();
}
