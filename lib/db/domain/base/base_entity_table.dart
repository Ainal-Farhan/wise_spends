import 'package:drift/drift.dart';
import 'package:wise_spends/utils/uuid_generator.dart';

abstract class BaseEntityTable extends Table {
  TextColumn get id => text().clientDefault(() => UuidGenerator().v4())();
  TextColumn get createdBy => text()();
  DateTimeColumn get dateCreated =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateUpdated => dateTime()();
  TextColumn get lastModifiedBy => text()();

  set dateUpdated(DateTimeColumn dateUpdated) => this.dateUpdated = dateUpdated;
  set lastModifiedBy(TextColumn lastModifiedBy) =>
      this.lastModifiedBy = lastModifiedBy;

  @override
  Set<Column> get primaryKey => {id};
}
