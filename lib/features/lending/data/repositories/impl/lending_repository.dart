import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/lending/data/repositories/i_lending_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

class LendingRepository extends ILendingRepository {
  LendingRepository() : super(AppDatabase());

  @override
  Future<List<LndngLending>> getAllLendings() {
    return db.select(db.lendingTable).get();
  }

  @override
  Future<LndngLending?> getLendingById(String id) {
    return (db.select(db.lendingTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<void> addLending({
    required String borrowerName,
    required double principalAmount,
    required DateTime lendingDate,
    DateTime? dueDate,
    String sourceSavingId = '',
    String? note,
    bool noAutoDeduct = false,
  }) async {
    final now = DateTime.now();
    final lendingId = UuidGenerator().v4();

    final effectiveSavingId =
        (noAutoDeduct || sourceSavingId.isEmpty) ? null : sourceSavingId;

    await db.into(db.lendingTable).insert(
      LendingTableCompanion.insert(
        id: Value(lendingId),
        borrowerName: borrowerName,
        principalAmount: principalAmount,
        lendingDate: lendingDate,
        dueDate: Value(dueDate),
        sourceSavingId: Value(effectiveSavingId),
        note: Value(note),
        status: const Value('active'),
        noAutoDeduct: Value(noAutoDeduct),
        createdBy: 'app',
        dateCreated: Value(now),
        dateUpdated: now,
        lastModifiedBy: 'app',
      ),
    );

    if (effectiveSavingId != null) {
      await db.into(db.transactionTable).insert(
        TransactionTableCompanion.insert(
          id: Value(UuidGenerator().v4()),
          type: TransactionType.lendingDisbursement,
          description: Value('Lent to $borrowerName'),
          amount: principalAmount,
          savingId: effectiveSavingId,
          lendingId: Value(lendingId),
          transactionDateTime: Value(lendingDate),
          note: Value(note),
          createdBy: 'app',
          dateCreated: Value(now),
          dateUpdated: now,
          lastModifiedBy: 'app',
        ),
      );

      await _adjustSavingBalance(effectiveSavingId, -principalAmount, now);
    }
  }

  @override
  Future<void> updateLending({
    required String id,
    required String borrowerName,
    required double principalAmount,
    required DateTime lendingDate,
    DateTime? dueDate,
    String? note,
    bool noAutoDeduct = false,
  }) async {
    await (db.update(db.lendingTable)..where((t) => t.id.equals(id))).write(
      LendingTableCompanion(
        borrowerName: Value(borrowerName),
        principalAmount: Value(principalAmount),
        lendingDate: Value(lendingDate),
        dueDate: Value(dueDate),
        note: Value(note),
        noAutoDeduct: Value(noAutoDeduct),
        dateUpdated: Value(DateTime.now()),
        lastModifiedBy: const Value('app'),
      ),
    );
  }

  @override
  Future<void> deleteLending(String id) async {
    await (db.delete(db.transactionTable)
          ..where((t) => t.lendingId.equals(id)))
        .go();
    await (db.delete(db.lendingRepaymentTable)
          ..where((t) => t.lendingId.equals(id)))
        .go();
    await (db.delete(db.lendingTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> settleLending(String id) async {
    await (db.update(db.lendingTable)..where((t) => t.id.equals(id))).write(
      LendingTableCompanion(
        status: const Value('settled'),
        dateUpdated: Value(DateTime.now()),
        lastModifiedBy: const Value('app'),
      ),
    );
  }

  @override
  Future<double> getOutstandingAmount(String lendingId) async {
    final lending = await getLendingById(lendingId);
    if (lending == null) return 0.0;
    final repayments = await (db.select(db.lendingRepaymentTable)
          ..where((t) => t.lendingId.equals(lendingId)))
        .get();
    final totalRepaid = repayments.fold<double>(0.0, (s, r) => s + r.amount);
    return (lending.principalAmount - totalRepaid).clamp(0.0, double.infinity);
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
  String getTypeName() => 'LendingTable';

  @override
  LndngLending fromJson(Map<String, dynamic> json) =>
      LndngLending.fromJson(json);
}
