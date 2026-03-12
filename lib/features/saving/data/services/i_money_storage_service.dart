import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/services/local/i_local_service.dart';

abstract class IMoneyStorageService extends ILocalService {
  IMoneyStorageService(super.repository);

  Stream<List<SvngMoneyStorage>> watchMoneyStorageListByUserId(
      final String userId);

  Stream<SvngMoneyStorage?> watchMoneyStorageById(final String moneyStorageId);

  Future<void> updatePart(
      final MoneyStorageTableCompanion moneyStorageTableCompanion);
}
