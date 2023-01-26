import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/saving/i_money_storage_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/saving/impl/money_storage_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/saving/i_money_storage_service.dart';

class MoneyStorageService extends IMoneyStorageService {
  final IMoneyStorageRepository _moneyStorageRepository =
      MoneyStorageRepository();

  MoneyStorageService() : super(MoneyStorageRepository());

  @override
  Future<void> updatePart(
    MoneyStorageTableCompanion moneyStorageTableCompanion,
  ) async {
    await _moneyStorageRepository.updatePart(
      moneyStorageTableCompanion: moneyStorageTableCompanion,
      moneyStorageId: moneyStorageTableCompanion.id.value,
    );
  }

  @override
  Stream<List<SvngMoneyStorage>> watchMoneyStorageListByUserId(String userId) {
    return _moneyStorageRepository.watchBasedOnUserId(userId);
  }
}
