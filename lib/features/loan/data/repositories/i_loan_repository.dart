import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/loan/loan_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ILoanRepository
    extends
        ICrudRepository<LoanTable, $LoanTableTable, LoanTableCompanion, LoanLoan> {
  ILoanRepository(AppDatabase db) : super(db, db.loanTable);

  Future<List<LoanLoan>> getAllLoans();
  Future<LoanLoan?> getLoanById(String id);
  Future<void> addLoan({
    required String borrowerName,
    required double principalAmount,
    required DateTime loanDate,
    DateTime? dueDate,
    required String sourceSavingId,
    String? note,
  });
  Future<void> updateLoan({
    required String id,
    required String borrowerName,
    required double principalAmount,
    required DateTime loanDate,
    DateTime? dueDate,
    required String sourceSavingId,
    String? note,
  });
  Future<void> deleteLoan(String id);
  Future<void> settleLoan(String id);
  Future<double> getOutstandingAmount(String loanId);
}
