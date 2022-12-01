abstract class DomainTableConstant {
  static const String commonTablePrefix = "Cmn";

  // Transaction Table Constant List
  static const String transactionTableTypeIn = 'in';
  static const String transactionTableTypeOut = 'out';
  static const List<String> transactionTableTypeList = [
    transactionTableTypeIn,
    transactionTableTypeOut,
  ];
}
