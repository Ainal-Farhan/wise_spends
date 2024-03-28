import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';
import 'package:wise_spends/service/local/i_local_service.dart';

abstract class IMoneyStorageService extends ILocalService {
  IMoneyStorageService(ICrudRepository repository) : super(repository);

  Stream<List<SvngMoneyStorage>> watchMoneyStorageListByUserId(
      final String userId);

  Stream<SvngMoneyStorage?> watchMoneyStorageById(final String moneyStorageId);

  Future<void> updatePart(
      final MoneyStorageTableCompanion moneyStorageTableCompanion);
}
