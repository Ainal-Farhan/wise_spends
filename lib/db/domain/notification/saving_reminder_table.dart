import 'package:drift/drift.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/base/reminder_table.dart';

@DataClassName('${DomainTableConstant.notificationTablePrefix}SavingReminder')
class SavingReminderTable extends ReminderTable {
  RealColumn get amount => real()();
  TextColumn get recurringType => text()();
}
