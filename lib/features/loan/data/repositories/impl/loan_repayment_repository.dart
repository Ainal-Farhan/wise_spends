import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/loan/data/repositories/i_loan_repayment_repository.dart';

class LoanRepaymentRepository extends ILoanRepaymentRepository {
  LoanRepaymentRepository() : super(AppDatabase());

  @override
  Future<List<LoanRepayment>> getRepaymentsForLoan(String loanId) {
    return (db.select(db.loanRepaymentTable)
      ..where((t) => t.loanId.equals(loanId))).get();
  }

  @override
  Future<void> addRepayment({
    required String loanId,
    required double amount,
    required String destinationSavingId,
    required DateTime repaymentDate,
    String? note,
  }) async {
    final now = DateTime.now();
    await db.into(db.loanRepaymentTable).insert(
      LoanRepaymentTableCompanion.insert(
        id: Value(UuidGenerator().v4()),
        loanId: loanId,
        amount: amount,
        destinationSavingId: destinationSavingId,
        repaymentDate: repaymentDate,
        note: Value(note),
        createdBy: 'app',
        dateCreated: Value(now),
        dateUpdated: now,
        lastModifiedBy: 'app',
      ),
    );
  }

  @override
  Future<void> deleteRepayment(String id) async {
    await (db.delete(db.loanRepaymentTable)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  String getTypeName() => 'LoanRepaymentTable';

  @override
  LoanRepayment fromJson(Map<String, dynamic> json) =>
      LoanRepayment.fromJson(json);
}
