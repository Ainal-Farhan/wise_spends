import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';

@DataClassName('ExchangeRate')
class ExchangeRateTable extends BaseEntityTable {
  TextColumn get fromCurrency => text()();
  TextColumn get toCurrency => text()();
  RealColumn get rate => real().customConstraint('NOT NULL CHECK (rate > 0)')();
  DateTimeColumn get rateDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {fromCurrency, toCurrency, rateDate},
  ];

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'fromCurrency': fromCurrency.name,
      'toCurrency': toCurrency.name,
      'rate': rate.name,
      'rateDate': rateDate.name,
    };
  }
}
