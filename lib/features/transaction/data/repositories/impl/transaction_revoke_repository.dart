import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_revoke_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_revoke_entity.dart';

class TransactionRevokeRepository extends ITransactionRevokeRepository {
  TransactionRevokeRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'TransactionRevokeTable';

  @override
  Future<TransactionRevokeEntity?> getByTransactionId(
    String transactionId,
  ) async {
    final query = db.select(db.transactionRevokeTable)
      ..where((tbl) => tbl.transactionId.equals(transactionId));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final row = rows.first;
    return TransactionRevokeEntity(
      id: row.id,
      transactionId: row.transactionId,
      reason: row.reason,
      revokedAt: row.revokedAt,
      createdAt: row.dateCreated,
      updatedAt: row.dateUpdated,
    );
  }

  @override
  Future<TransactionRevokeEntity> revokeTransaction({
    required String transactionId,
    required String reason,
    required DateTime revokedAt,
  }) async {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    final companion = TransactionRevokeTableCompanion.insert(
      id: Value(id),
      transactionId: transactionId,
      reason: reason,
      revokedAt: revokedAt,
      createdBy: 'system',
      dateCreated: Value(now),
      dateUpdated: now,
      lastModifiedBy: 'system',
    );

    await db.into(db.transactionRevokeTable).insert(companion);

    return TransactionRevokeEntity(
      id: id,
      transactionId: transactionId,
      reason: reason,
      revokedAt: revokedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  TrnsctnRevoke fromJson(Map<String, dynamic> json) =>
      TrnsctnRevoke.fromJson(json);
}
