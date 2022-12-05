abstract class DomainTableConstant {
  static const String commonTablePrefix = "Cmmn";
  static const String expenseTablePrefix = "Expns";
  static const String transactionTablePrefix = "Trnsctn";
  static const String savingTablePrefix = "Svng";
  static const String masterdataTablePrefix = "Mstrdt";
  static const String notificationTablePrefix = "Ntfctn";

  // Transaction Table Constant List
  static const String transactionTableTypeIn = 'in';
  static const String transactionTableTypeOut = 'out';
  static const List<String> transactionTableTypeList = [
    transactionTableTypeIn,
    transactionTableTypeOut,
  ];
}
