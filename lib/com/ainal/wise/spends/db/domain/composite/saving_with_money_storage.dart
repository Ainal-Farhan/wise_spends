import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';

class SavingWithMoneyStorage {
  final SvngSaving saving;
  SvngMoneyStorage? moneyStorage;

  SavingWithMoneyStorage({
    required this.saving,
    this.moneyStorage,
  });

  @override
  String toString() => (StringBuffer('SavingWithTransactions(')
        ..write('saving: $saving, ')
        ..write('transactions: $moneyStorage')
        ..write(')'))
      .toString();
}
