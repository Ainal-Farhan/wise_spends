import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';

abstract class BaseEntityTable extends Table {
  TextColumn get id => text().clientDefault(() => UuidGenerator().v4())();
  TextColumn get createdBy => text()();
  DateTimeColumn get dateCreated =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateUpdated => dateTime()();
  TextColumn get lastModifiedBy => text()();

  @override
  Set<Column> get primaryKey => {id};

  Map<String, dynamic> toMapFromSubClass();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = toMapFromSubClass();

    map.addAll({
      "id": id.name,
      "createdBy": createdBy.name,
      "dateCreated": dateCreated.name,
      "dateUpdated": dateUpdated.name,
      "lastModifiedBy": lastModifiedBy.name,
    });

    return map;
  }
}
