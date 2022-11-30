import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/db_connection.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/common/saving_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/common/transaction_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/common/user_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/uuid_generator.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [UserTable, TransactionTable, SavingTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase._privateConstructor() : super(DbConnection.openConnection());
  static final AppDatabase _appDatabase = AppDatabase._privateConstructor();
  factory AppDatabase() {
    return _appDatabase;
  }

  @override
  int get schemaVersion => 1;
}
