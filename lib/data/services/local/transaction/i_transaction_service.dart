import 'package:wise_spends/data/services/local/i_local_service.dart';

abstract class ITransactionService extends ILocalService {
  ITransactionService(super.repository);

  Future<void> deleteAllBasedOnSavingId(String savingId);
}
