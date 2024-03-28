import 'package:drift/drift.dart';
import 'package:wise_spends/utils/uuid_generator.dart';

abstract class BaseEntityTable extends Table {
  TextColumn get id => text().clientDefault(() => UuidGenerator().v4())();
  DateTimeColumn get dateCreated =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateUpdated => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}