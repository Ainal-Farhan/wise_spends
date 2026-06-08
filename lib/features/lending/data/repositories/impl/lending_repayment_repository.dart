import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/lending/data/repositories/i_lending_repayment_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

class LendingRepaymentRepository extends ILendingRepaymentRepository {
  LendingRepaymentRepository() : super(AppDatabase());

  @override
  Future<List<LndngRepayment>> getRepaymentsForLending(String lendingId) {
    return (db.select(db.lendingRepaymentTable)
          ..where((t) => t.lendingId.equals(lendingId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.repaymentDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  @override
  Future<void> addRepayment({
    required String lendingId,
    required double amount,
    required String destinationSavingId,
    required DateTime repaymentDate,
    String? note,
  }) async {
    final now = DateTime.now();

    final lending = await (db.select(db.lendingTable)
          ..where((t) => t.id.equals(lendingId)))
        .getSingleOrNull();
    final borrowerName = lending?.borrowerName ?? 'Unknown';

    await db.into(db.lendingRepaymentTable).insert(
      LendingRepaymentTableCompanion.insert(
        id: Value(UuidGenerator().v4()),
        lendingId: lendingId,
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

    await db.into(db.transactionTable).insert(
      TransactionTableCompanion.insert(
        id: Value(UuidGenerator().v4()),
        type: TransactionType.lendingRepayment,
        description: Value('Repayment from $borrowerName'),
        amount: amount,
        savingId: destinationSavingId,
        lendingId: Value(lendingId),
        transactionDateTime: Value(repaymentDate),
        note: Value(note),
        createdBy: 'app',
        dateCreated: Value(now),
        dateUpdated: now,
        lastModifiedBy: 'app',
      ),
    );

    await _adjustSavingBalance(destinationSavingId, amount, now);

    // Auto-settle if fully repaid
    if (lending != null) {
      final repayments = await (db.select(db.lendingRepaymentTable)
            ..where((t) => t.lendingId.equals(lendingId)))
          .get();
      final totalRepaid = repayments.fold<double>(0.0, (s, r) => s + r.amount);
      if (totalRepaid >= lending.principalAmount) {
        await (db.update(db.lendingTable)
              ..where((t) => t.id.equals(lendingId)))
            .write(
              LendingTableCompanion(
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
    await (db.delete(db.lendingRepaymentTable)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> _adjustSavingBalance(
    String savingId,
    double delta,
    DateTime now,
  ) async {
    final saving = await (db.select(db.savingTable)
          ..where((t) => t.id.equals(savingId)))
        .getSingleOrNull();
    if (saving == null) return;
    await (db.update(db.savingTable)..where((t) => t.id.equals(savingId)))
        .write(
          SavingTableCompanion(
            currentAmount: Value(saving.currentAmount + delta),
            dateUpdated: Value(now),
            lastModifiedBy: const Value('app'),
          ),
        );
  }

  @override
  String getTypeName() => 'LendingRepaymentTable';

  @override
  LndngRepayment fromJson(Map<String, dynamic> json) =>
      LndngRepayment.fromJson(json);
}
