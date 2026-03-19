import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/index.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_revoke_entity.dart';

abstract class ITransactionRevokeRepository
    extends
        ICrudRepository<
          TransactionRevokeTable,
          $TransactionRevokeTableTable,
          TransactionRevokeTableCompanion,
          TrnsctnRevoke
        > {
  ITransactionRevokeRepository(AppDatabase db)
    : super(db, db.transactionRevokeTable);

  /// Returns the revoke record for the given [transactionId], or null if not revoked.
  Future<TransactionRevokeEntity?> getByTransactionId(String transactionId);

  /// Creates a new revoke record.
  /// Throws if a revoke record already exists for the transaction.
  Future<TransactionRevokeEntity> revokeTransaction({
    required String transactionId,
    required String reason,
    required DateTime revokedAt,
  });
}
