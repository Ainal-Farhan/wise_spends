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

  Map<String, dynamic> toMapFromSubClass();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = toMapFromSubClass();

    map.addAll(
    {
      "id": id.toString(),
      "createdBy": createdBy.toString(),
      "dateCreated": dateCreated.toString(),
      "dateUpdated": dateUpdated.toString(),
      "lastModifiedBy": lastModifiedBy.toString()
    });

    return map;
  }
}
