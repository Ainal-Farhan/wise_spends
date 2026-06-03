import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/loan/data/repositories/i_loan_repayment_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

class LoanRepaymentRepository extends ILoanRepaymentRepository {
  LoanRepaymentRepository() : super(AppDatabase());

  @override
  Future<List<LoanRepayment>> getRepaymentsForLoan(String loanId) {
    return (db.select(
      db.loanRepaymentTable,
    )..where((t) => t.loanId.equals(loanId))).get();
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

    // Fetch borrower name for the transaction description
    final loan = await (db.select(
      db.loanTable,
    )..where((t) => t.id.equals(loanId))).getSingleOrNull();
    final borrowerName = loan?.borrowerName ?? 'Unknown';

    // 1. Insert the repayment record
    await db
        .into(db.loanRepaymentTable)
        .insert(
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

    // 2. Create a loanRepayment transaction that credits the destination saving
    await db
        .into(db.transactionTable)
        .insert(
          TransactionTableCompanion.insert(
            id: Value(UuidGenerator().v4()),
            type: TransactionType.loanRepayment,
            description: Value('Repayment from $borrowerName'),
            amount: amount,
            savingId: destinationSavingId,
            loanId: Value(loanId),
            transactionDateTime: Value(repaymentDate),
            note: Value(note),
            createdBy: 'app',
            dateCreated: Value(now),
            dateUpdated: now,
            lastModifiedBy: 'app',
          ),
        );

    // 3. Credit the destination saving
    await _adjustSavingBalance(destinationSavingId, amount, now);

    // 4. Auto-settle the loan if fully repaid
    if (loan != null) {
      final repayments = await (db.select(
        db.loanRepaymentTable,
      )..where((t) => t.loanId.equals(loanId))).get();
      final totalRepaid = repayments.fold<double>(
        0.0,
        (sum, r) => sum + r.amount,
      );
      if (totalRepaid >= loan.principalAmount) {
        await (db.update(
          db.loanTable,
        )..where((t) => t.id.equals(loanId))).write(
          LoanTableCompanion(
            status: const Value('settled'),
            dateUpdated: Value(now),
            lastModifiedBy: const Value('app'),
          ),
        );
      }
    }
  }

  @override
  Future<void> deleteRepayment(String id) async {
    await (db.delete(
      db.loanRepaymentTable,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<void> _adjustSavingBalance(
    String savingId,
    double delta,
    DateTime now,
  ) async {
    final saving = await (db.select(
      db.savingTable,
    )..where((t) => t.id.equals(savingId))).getSingleOrNull();
    if (saving == null) return;
    final newAmount = saving.currentAmount + delta;
    await (db.update(
      db.savingTable,
    )..where((t) => t.id.equals(savingId))).write(
      SavingTableCompanion(
        currentAmount: Value(newAmount),
        dateUpdated: Value(now),
        lastModifiedBy: const Value('app'),
      ),
    );
  }

  @override
  String getTypeName() => 'LoanRepaymentTable';

  @override
  LoanRepayment fromJson(Map<String, dynamic> json) =>
      LoanRepayment.fromJson(json);
}
