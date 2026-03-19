import 'package:equatable/equatable.dart';

class TransactionRevokeEntity extends Equatable {
  final String id;
  final String transactionId;
  final String reason;
  final DateTime revokedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionRevokeEntity({
    required this.id,
    required this.transactionId,
    required this.reason,
    required this.revokedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    transactionId,
    reason,
    revokedAt,
    createdAt,
    updatedAt,
  ];

  TransactionRevokeEntity copyWith({
    String? id,
    String? transactionId,
    String? reason,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionRevokeEntity(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      reason: reason ?? this.reason,
      revokedAt: revokedAt ?? this.revokedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
