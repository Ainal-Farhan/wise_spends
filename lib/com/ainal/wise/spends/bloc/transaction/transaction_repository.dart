import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_provider.dart';

class TransactionRepository {
  final TransactionProvider _transactionProvider = TransactionProvider();

  TransactionRepository();

  void test(bool isError) {
    _transactionProvider.test(isError);
  }
}
