import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/repository/saving/i_money_storage_repository.dart';
import 'package:wise_spends/service/local/saving/i_money_storage_service.dart';
import 'package:wise_spends/util/singleton_util.dart';

class MoneyStorageService extends IMoneyStorageService {
  final IMoneyStorageRepository _moneyStorageRepository =
      SingletonUtil.getSingleton<IRepositoryLocator>()
          .getMoneyStorageRepository();

  MoneyStorageService()
      : super(SingletonUtil.getSingleton<IRepositoryLocator>()
            .getMoneyStorageRepository());

  @override
  Future<void> updatePart(
    MoneyStorageTableCompanion moneyStorageTableCompanion,
  ) async {
    await _moneyStorageRepository.updatePart(
      tableCompanion: moneyStorageTableCompanion,
      id: moneyStorageTableCompanion.id.value,
    );
  }

  @override
  Stream<List<SvngMoneyStorage>> watchMoneyStorageListByUserId(String userId) {
    return _moneyStorageRepository.watchBasedOnUserId(userId);
  }

  @override
  Stream<SvngMoneyStorage?> watchMoneyStorageById(String moneyStorageId) {
    return _moneyStorageRepository.watchById(id: moneyStorageId);
  }
}
