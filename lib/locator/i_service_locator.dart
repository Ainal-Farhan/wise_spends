import 'package:wise_spends/locator/i_locator.dart';
import 'package:wise_spends/service/local/common/i_user_service.dart';
import 'package:wise_spends/service/local/masterdata/i_group_reference_service.dart';
import 'package:wise_spends/service/local/masterdata/i_reference_service.dart';
import 'package:wise_spends/service/local/saving/i_money_storage_service.dart';
import 'package:wise_spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/service/local/transaction/i_transaction_service.dart';

abstract class IServiceLocator extends ILocator {
  IUserService getUserService();
  IGroupReferenceService getGroupReferenceService();
  IReferenceService getReferenceService();
  IMoneyStorageService getMoneyStorageService();
  ISavingService getSavingService();
  ITransactionService getTransactionService();
}
