import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/loan/data/repositories/i_loan_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

class LoanRepository extends ILoanRepository {
  LoanRepository() : super(AppDatabase());

  @override
  Future<List<LoanLoan>> getAllLoans() {
    return db.select(db.loanTable).get();
  }

  @override
  Future<LoanLoan?> getLoanById(String id) {
    return (db.select(
      db.loanTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<void> addLoan({
    required String borrowerName,
    required double principalAmount,
    required DateTime loanDate,
    DateTime? dueDate,
    required String sourceSavingId,
    String? note,
  }) async {
    final now = DateTime.now();
    final loanId = UuidGenerator().v4();

    // 1. Insert the loan record
    await db
        .into(db.loanTable)
        .insert(
          LoanTableCompanion.insert(
            id: Value(loanId),
            borrowerName: borrowerName,
            principalAmount: principalAmount,
            loanDate: loanDate,
            dueDate: Value(dueDate),
            sourceSavingId: sourceSavingId,
            note: Value(note),
            status: const Value('active'),
            createdBy: 'app',
            dateCreated: Value(now),
            dateUpdated: now,
            lastModifiedBy: 'app',
          ),
        );

    // 2. Create a loanDisbursement transaction that debits the source saving
    await db
        .into(db.transactionTable)
        .insert(
          TransactionTableCompanion.insert(
            id: Value(UuidGenerator().v4()),
            type: TransactionType.loanDisbursement,
            description: Value('Loan to $borrowerName'),
            amount: principalAmount,
            savingId: sourceSavingId,
            loanId: Value(loanId),
            transactionDateTime: Value(loanDate),
            note: Value(note),
            createdBy: 'app',
            dateCreated: Value(now),
            dateUpdated: now,
            lastModifiedBy: 'app',
          ),
        );

    // 3. Deduct from source saving
    await _adjustSavingBalance(sourceSavingId, -principalAmount, now);
  }

  @override
  Future<void> updateLoan({
    required String id,
    required String borrowerName,
    required double principalAmount,
    required DateTime loanDate,
    DateTime? dueDate,
    required String sourceSavingId,
    String? note,
  }) async {
    await (db.update(db.loanTable)..where((t) => t.id.equals(id))).write(
      LoanTableCompanion(
        borrowerName: Value(borrowerName),
        principalAmount: Value(principalAmount),
        loanDate: Value(loanDate),
        dueDate: Value(dueDate),
        sourceSavingId: Value(sourceSavingId),
        note: Value(note),
        dateUpdated: Value(DateTime.now()),
        lastModifiedBy: const Value('app'),
      ),
    );
  }

  @override
  Future<void> deleteLoan(String id) async {
    // Delete linked transactions first
    await (db.delete(
      db.transactionTable,
    )..where((t) => t.loanId.equals(id))).go();
    // Delete repayments
    await (db.delete(
      db.loanRepaymentTable,
    )..where((t) => t.loanId.equals(id))).go();
    await (db.delete(db.loanTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> settleLoan(String id) async {
    await (db.update(db.loanTable)..where((t) => t.id.equals(id))).write(
      LoanTableCompanion(
        status: const Value('settled'),
        dateUpdated: Value(DateTime.now()),
        lastModifiedBy: const Value('app'),
      ),
    );
  }

  @override
  Future<double> getOutstandingAmount(String loanId) async {
    final loan = await getLoanById(loanId);
    if (loan == null) return 0.0;
    final repayments = await (db.select(
      db.loanRepaymentTable,
    )..where((t) => t.loanId.equals(loanId))).get();
    final totalRepaid = repayments.fold<double>(
      0.0,
      (sum, r) => sum + r.amount,
    );
    return (loan.principalAmount - totalRepaid).clamp(0.0, double.infinity);
  }

  Future<void> _adjustSavingBalance(
    String savingId,
    double delta,
    DateTime now,
  ) async {
    final savings = await (db.select(
      db.savingTable,
    )..where((t) => t.id.equals(savingId))).getSingleOrNull();
    if (savings == null) return;
    final newAmount = savings.currentAmount + delta;
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
  String getTypeName() => 'LoanTable';

  @override
  LoanLoan fromJson(Map<String, dynamic> json) => LoanLoan.fromJson(json);
}
