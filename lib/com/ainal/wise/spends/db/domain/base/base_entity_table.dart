import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/uuid_generator.dart';

abstract class BaseEntityTable extends Table {
  TextColumn get id => text().clientDefault(() => UuidGenerator().v4())();
  DateTimeColumn get dateCreated => dateTime()();
  DateTimeColumn get dateUpdated => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
