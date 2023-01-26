import 'package:dropdown_textfield/dropdown_textfield.dart';

abstract class MoneyStorageConstant {
  static const String moneyStorageTypePhysicalLabel = 'Physical';
  static const String moneyStorageTypePhysicalValue = 'PHYSICAL';

  static const String moneyStorageTypeDigitalLabel = 'Digital';
  static const String moneyStorageTypeDigitalValue = 'DIGITAL';

  static final List<DropDownValueModel> moneyStorageTypeDropDownValueModelList =
      List.unmodifiable([
    const DropDownValueModel(
        name: moneyStorageTypePhysicalLabel,
        value: moneyStorageTypePhysicalValue),
    const DropDownValueModel(
        name: moneyStorageTypeDigitalLabel,
        value: moneyStorageTypeDigitalValue),
  ]);
}
