import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

abstract class IHomeRepository {
  Future<List<ListSavingVO>> getDailyUsageSavings();
  Future<List<ListSavingVO>> getCreditSavings();
  Future<List<ListSavingVO>> getAllSavings();
  Future<void> makeTransaction({
    required String sourceSavingId,
    String? destinationSavingId,
    required double amount,
    required String transactionType,
    String? reference,
  });
}

class HomeRepository implements IHomeRepository {
  final savingManager = SingletonUtil.getSingleton<IManagerLocator>()!
      .getSavingManager();

  @override
  Future<List<ListSavingVO>> getDailyUsageSavings() async {
    try {
      final allSavings = await savingManager.loadListSavingVOList();
      return allSavings.where((saving) {
        final type = SavingTableType.findByValue(saving.saving.type);
        return type == SavingTableType.dailyUsage;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load daily usage savings: $e');
    }
  }

  @override
  Future<List<ListSavingVO>> getCreditSavings() async {
    try {
      final allSavings = await savingManager.loadListSavingVOList();
      return allSavings.where((saving) {
        final type = SavingTableType.findByValue(saving.saving.type);
        return type == SavingTableType.credit;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load credit savings: $e');
    }
  }

  @override
  Future<List<ListSavingVO>> getAllSavings() async {
    try {
      return await savingManager.loadListSavingVOList();
    } catch (e) {
      throw Exception('Failed to load all savings: $e');
    }
  }

  @override
  Future<void> makeTransaction({
    required String sourceSavingId,
    String? destinationSavingId,
    required double amount,
    required String transactionType,
    String? reference,
  }) async {
    try {
      // Update the source saving's current amount based on transaction type
      String transactionTypeFormatted = '';
      double transactionAmount = amount;

      if (transactionType == 'out' ||
          (transactionType == 'transfer' && destinationSavingId == null)) {
        transactionTypeFormatted = 'withdrawal';
      } else if (transactionType == 'in') {
        transactionTypeFormatted = 'deposit';
      } else if (transactionType == 'transfer' && destinationSavingId != null) {
        // Handle transfer - subtract from source, add to destination
        transactionTypeFormatted = 'transfer_out';

        // Also make an entry for the destination
        await savingManager.updateSavingCurrentAmount(
          savingId: destinationSavingId,
          transactionType: 'transfer_in',
          transactionAmount: amount,
        );
      }

      await savingManager.updateSavingCurrentAmount(
        savingId: sourceSavingId,
        transactionType: transactionTypeFormatted,
        transactionAmount: transactionAmount,
      );
    } catch (e) {
      throw Exception('Failed to make transaction: $e');
    }
  }
}
