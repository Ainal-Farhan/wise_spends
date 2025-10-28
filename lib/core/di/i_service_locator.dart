import 'package:wise_spends/core/di/i_locator.dart';
import 'package:wise_spends/data/services/local/common/i_user_service.dart';
import 'package:wise_spends/data/services/local/masterdata/i_group_reference_service.dart';
import 'package:wise_spends/data/services/local/masterdata/i_reference_service.dart';
import 'package:wise_spends/data/services/local/saving/i_money_storage_service.dart';
import 'package:wise_spends/data/services/local/saving/i_saving_service.dart';
import 'package:wise_spends/data/services/local/transaction/i_transaction_service.dart';

abstract class IServiceLocator extends ILocator {
  IUserService getUserService();
  IGroupReferenceService getGroupReferenceService();
  IReferenceService getReferenceService();
  IMoneyStorageService getMoneyStorageService();
  ISavingService getSavingService();
  ITransactionService getTransactionService();
}
