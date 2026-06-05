import 'package:dropdown_textfield/dropdown_textfield.dart';

enum SavingTableType {
  dailyUsage("Daily Usage", "DAILY_USAGE", 1),
  credit("Credit", "CREDIT", 2),
  emergency("Emergency", "EMERGENCY", 3),
  saving("Saving", "SAVING", 4);

  final String label;
  final String value;
  final int priority;

  const SavingTableType(this.label, this.value, this.priority);

  static SavingTableType? findByValue(String val) {
    for (SavingTableType savingTableType in SavingTableType.values) {
      if (savingTableType.value == val) {
        return savingTableType;
      }
    }

    return null;
  }

  static SavingTableType? findByLabel(String label) {
    final normalized = label.trim().toLowerCase();
    for (SavingTableType savingTableType in SavingTableType.values) {
      if (savingTableType.label.toLowerCase() == normalized ||
          savingTableType.value.toLowerCase() == normalized) {
        return savingTableType;
      }
    }

    return null;
  }

  static String normalizeInput(String input) {
    final builtInType = findByLabel(input);
    return builtInType?.value ?? input.trim();
  }

  static String displayLabel(String value) {
    return findByValue(value)?.label ?? value;
  }

  static List<DropDownValueModel> retrieveAllAsDropDownValueModel() {
    List<DropDownValueModel> savingTypeList = [];
    for (SavingTableType savingTableType in SavingTableType.values) {
      savingTypeList.add(
        DropDownValueModel(name: savingTableType.label, value: savingTableType),
      );
    }

    return savingTypeList;
  }
}
