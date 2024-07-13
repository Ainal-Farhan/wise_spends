import 'package:wise_spends/locator/i_locator.dart';
import 'package:wise_spends/repository/common/i_user.repository.dart';
import 'package:wise_spends/repository/expense/i_commitment_detail_repository.dart';
import 'package:wise_spends/repository/expense/i_commitment_repository.dart';
import 'package:wise_spends/repository/expense/i_expense_repository.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';
import 'package:wise_spends/repository/masterdata/i_group_reference_repository.dart';
import 'package:wise_spends/repository/masterdata/i_reference_repository.dart';
import 'package:wise_spends/repository/saving/i_money_storage_repository.dart';
import 'package:wise_spends/repository/saving/i_saving_repository.dart';
import 'package:wise_spends/repository/transaction/i_transaction_repository.dart';

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
}
