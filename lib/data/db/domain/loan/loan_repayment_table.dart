import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/loan/loan_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';

@DataClassName("${DomainTableConstant.loanTablePrefix}Repayment")
class LoanRepaymentTable extends BaseEntityTable {
  TextColumn get loanId => text().references(LoanTable, #id)();
  RealColumn get amount => real()();
  TextColumn get destinationSavingId => text().references(SavingTable, #id)();
  DateTimeColumn get repaymentDate => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'loanId': loanId.name,
      'amount': amount.name,
      'destinationSavingId': destinationSavingId.name,
      'repaymentDate': repaymentDate.name,
      'note': note.name,
    };
  }
}
