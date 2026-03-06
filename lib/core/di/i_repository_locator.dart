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
}
