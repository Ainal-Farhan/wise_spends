import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_tag_table.dart';

@DataClassName('TransactionTagMap')
class TransactionTagMapTable extends BaseEntityTable {
  TextColumn get transactionId => text().references(TransactionTable, #id)();
  TextColumn get tagId => text().references(TransactionTagTable, #id)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {transactionId, tagId}
  ];

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'transactionId': transactionId.toString(),
      'tagId': tagId.toString(),
    };
  }
}
