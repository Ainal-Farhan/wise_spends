import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';

class SavingWithTransactions {
  final SvngSaving saving;
  final List<TrnsctnTransaction> transactions;

  SavingWithTransactions({required this.transactions, required this.saving});

  @override
  String toString() => (StringBuffer('SavingWithTransactions(')
        ..write('saving: $saving, ')
        ..write('transactions: $transactions')
        ..write(')'))
      .toString();
}
