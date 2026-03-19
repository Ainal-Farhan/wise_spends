import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';

/// Transaction revoke table - stores information about revoked transactions.
///
/// Each transaction can only be revoked once (enforced by unique constraint).
/// This table maintains an audit trail of transaction revocations including
/// the reason and timestamp.
@DataClassName("${DomainTableConstant.transactionTablePrefix}Revoke")
class TransactionRevokeTable extends BaseEntityTable {
  /// Foreign key to the transaction being revoked.
  /// Each transaction can only appear once (unique constraint below).
  TextColumn get transactionId =>
      text().references(TransactionTable, #id)();

  /// The reason provided by the user for revoking this transaction.
  TextColumn get reason => text().withLength(min: 1, max: 500)();

  /// The date and time when the transaction was revoked.
  DateTimeColumn get revokedAt => dateTime()();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  /// Each transaction can only be revoked once.
  @override
  List<Set<Column>> get uniqueKeys => [
    {transactionId},
  ];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'transactionId': transactionId.name,
    'reason': reason.name,
    'revokedAt': revokedAt.name,
  };
}
