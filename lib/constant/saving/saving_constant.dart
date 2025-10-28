abstract class SavingConstant {
  static const String savingTransactionIn = 'IN';
  static const String savingTransactionOut = 'OUT';
  static const String withdrawal = 'withdrawal';
  static const String deposit = 'deposit';
  static const String transferOut = 'transfer_out';
  static const String transferIn = 'transfer_in';

  static final List<String> savingTransactionList = List.unmodifiable([
    savingTransactionIn,
    savingTransactionOut,
  ]);
}
