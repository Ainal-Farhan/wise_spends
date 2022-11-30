import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';

class SavingsRepository {
  final SavingsProvider _savingsProvider = SavingsProvider();

  SavingsRepository();

  void test(bool isError) {
    _savingsProvider.test(isError);
  }
}