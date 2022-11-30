import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';

class SavingWithTransactions {
  final CmnSaving saving;
  final List<CmnTransaction> transactions;

  SavingWithTransactions({required this.transactions, required this.saving});
}
