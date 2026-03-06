import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';

// ---------------------------------------------------------------------------
// Payee table — normalises recipient information
// ---------------------------------------------------------------------------
// Previously recipient fields (name, account number, bank) were duplicated on
// every CommitmentTaskTable row. Extracting them into PayeeTable means:
//   - One payee record is reused across many tasks.
//   - Updating a payee's bank details fixes all linked tasks automatically.
//   - The task table stays lean.

@DataClassName("${DomainTableConstant.expenseTablePrefix}Payee")
class PayeeTable extends BaseEntityTable {
  TextColumn get name => text()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get bankName => text().nullable()();

  /// Optional free-text for any extra payee info (e.g. PayNow UEN, DuitNow ID).
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() => {
        'name': name.name,
        'accountNumber': accountNumber.name,
        'bankName': bankName.name,
        'note': note.name,
      };
}
