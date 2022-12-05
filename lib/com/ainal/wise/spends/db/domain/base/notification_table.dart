import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';

class NotificationTable extends BaseEntityTable {
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get activeStartDate => dateTime()();
  TextColumn get notificationType => text()();
}
