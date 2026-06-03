import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/loan/loan_repayment_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ILoanRepaymentRepository
    extends
        ICrudRepository<
          LoanRepaymentTable,
          $LoanRepaymentTableTable,
          LoanRepaymentTableCompanion,
          LoanRepayment
        > {
  ILoanRepaymentRepository(AppDatabase db) : super(db, db.loanRepaymentTable);

  Future<List<LoanRepayment>> getRepaymentsForLoan(String loanId);
  Future<void> addRepayment({
    required String loanId,
    required double amount,
    required String destinationSavingId,
    required DateTime repaymentDate,
    String? note,
  });
  Future<void> deleteRepayment(String id);
}
