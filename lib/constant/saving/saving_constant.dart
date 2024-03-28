abstract class SavingConstant {
  static const String savingTransactionIn = 'IN';
  static const String savingTransactionOut = 'OUT';

  static final List<String> savingTransactionList = List.unmodifiable([
    savingTransactionIn,
    savingTransactionOut,
  ]);
}
