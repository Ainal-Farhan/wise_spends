import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/db/domain/common/user_table.dart';

@DataClassName("${DomainTableConstant.lendingTablePrefix}Lending")
class LendingTable extends BaseEntityTable {
  TextColumn get borrowerName => text()();
  RealColumn get principalAmount => real()();
  DateTimeColumn get lendingDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get sourceSavingId =>
      text().nullable().references(SavingTable, #id)();
  TextColumn get note => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get userId => text().nullable().references(UserTable, #id)();

  /// When true the disbursement came from outside the app,
  /// so no saving-account deduction is made on creation.
  BoolColumn get noAutoDeduct =>
      boolean().withDefault(const Constant(false))();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'borrowerName': borrowerName.name,
      'principalAmount': principalAmount.name,
      'lendingDate': lendingDate.name,
      'dueDate': dueDate.name,
      'sourceSavingId': sourceSavingId.name,
      'note': note.name,
      'status': status.name,
      'userId': userId.name,
      'noAutoDeduct': noAutoDeduct.name,
    };
  }
}
