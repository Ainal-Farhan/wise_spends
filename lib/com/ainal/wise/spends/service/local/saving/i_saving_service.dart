import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_local_service.dart';

abstract class ISavingService extends ILocalService {
  ISavingService(ICrudRepository repository) : super(repository);

  Stream<List<SavingWithTransactions>> watchAllSavingWithTransactions(
      final String userId);

  Stream<List<SvngSaving>> watchAllSavingBasedOnMoneyStorageId(
      final String moneyStorageId);

  Stream<SvngSaving> watchSavingById(final String savingId);

  Future<void> updatePart(final SavingTableCompanion savingTableCompanion);
}
