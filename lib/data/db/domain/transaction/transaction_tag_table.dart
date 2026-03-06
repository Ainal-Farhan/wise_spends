import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';

@DataClassName('TransactionTag')
class TransactionTagTable extends BaseEntityTable {
  TextColumn get name => text().unique()();
  TextColumn get colorHex => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {'name': name.name, 'colorHex': colorHex.name};
  }
}
