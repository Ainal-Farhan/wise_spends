import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_local_service.dart';

abstract class ITransactionService extends ILocalService {
  ITransactionService(ICrudRepository repository) : super(repository);

  Future<void> deleteAllBasedOnSavingId(String savingId);
}
