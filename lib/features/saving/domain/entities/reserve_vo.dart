import 'package:equatable/equatable.dart';

/// Reservation type enum - identifies the source of the reservation
enum ReserveType {
  /// Reserved for pending commitment tasks (will be deducted when task completes)
  commitmentTask,

  /// Reserved for budget plan linked account allocation
  budgetPlanAllocation,
}

/// VO for a single reservation entry - represents funds that are reserved
/// and cannot be used for other transactions
class ReserveVO extends Equatable {
  /// Unique identifier for this reservation (could be task ID or linked account ID)
  final String id;

  /// The amount that is reserved
  final double amount;

  /// Human-readable description of why this amount is reserved
  final String description;

  /// Type of reservation (commitment task or budget plan allocation)
  final ReserveType type;

  /// Optional reference to the source saving ID (for commitment tasks)
  final String? sourceSavingId;

  /// Optional reference to the target saving ID (for internal transfers)
  final String? targetSavingId;

  /// Optional reference to the budget plan ID (for budget plan allocations)
  final String? planId;

  /// Optional reference to the linked account ID (for budget plan allocations)
  final String? linkedAccountId;

  /// Whether this reservation is for a completed task (should not affect transferable amount)
  final bool isCompleted;

  const ReserveVO({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    this.sourceSavingId,
    this.targetSavingId,
    this.planId,
    this.linkedAccountId,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        type,
        sourceSavingId,
        targetSavingId,
        planId,
        linkedAccountId,
        isCompleted,
      ];

  /// Creates a copy with updated fields
  ReserveVO copyWith({
    String? id,
    double? amount,
    String? description,
    ReserveType? type,
    String? sourceSavingId,
    String? targetSavingId,
    String? planId,
    String? linkedAccountId,
    bool? isCompleted,
  }) {
    return ReserveVO(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      sourceSavingId: sourceSavingId ?? this.sourceSavingId,
      targetSavingId: targetSavingId ?? this.targetSavingId,
      planId: planId ?? this.planId,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Converts to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'type': type.name,
      'sourceSavingId': sourceSavingId,
      'targetSavingId': targetSavingId,
      'planId': planId,
      'linkedAccountId': linkedAccountId,
      'isCompleted': isCompleted,
    };
  }

  /// Creates from JSON map
  factory ReserveVO.fromJson(Map<String, dynamic> json) {
    return ReserveVO(
      id: json['id'] as String,
      amount: json['amount'] as double,
      description: json['description'] as String,
      type: ReserveType.values.firstWhere(
        (e) => e.name == json['type'] as String,
      ),
      sourceSavingId: json['sourceSavingId'] as String?,
      targetSavingId: json['targetSavingId'] as String?,
      planId: json['planId'] as String?,
      linkedAccountId: json['linkedAccountId'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Display label for the reservation type
  String get typeLabel {
    switch (type) {
      case ReserveType.commitmentTask:
        return 'Commitment Task';
      case ReserveType.budgetPlanAllocation:
        return 'Budget Plan Allocation';
    }
  }

  /// Whether this reservation affects the transferable amount
  /// (completed reservations don't affect it since they've already been processed)
  bool get affectsTransferable => !isCompleted;
}

/// Summary VO for all reservations on a single savings account
class SavingsReserveSummary extends Equatable {
  /// The savings account ID this summary is for
  final String savingId;

  /// List of all individual reservations
  final List<ReserveVO> reservations;

  /// Total amount reserved (sum of all reservations that affect transferable amount)
  final double totalReserved;

  /// Current amount in the savings account
  final double currentAmount;

  const SavingsReserveSummary({
    required this.savingId,
    required this.reservations,
    required this.totalReserved,
    required this.currentAmount,
  });

  /// Transferable amount (current amount minus total reserved)
  double get transferableAmount {
    final amount = currentAmount - totalReserved;
    // Prevent negative transferable amount
    return amount < 0 ? 0 : amount;
  }

  /// Reserved amount from commitment tasks
  double get commitmentTaskReserved {
    return reservations
        .where((r) => r.type == ReserveType.commitmentTask && r.affectsTransferable)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  /// Reserved amount from budget plan allocations
  double get budgetPlanAllocationReserved {
    return reservations
        .where((r) => r.type == ReserveType.budgetPlanAllocation && r.affectsTransferable)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  /// Whether there are any active reservations
  bool get hasReservations =>
      reservations.any((r) => r.affectsTransferable);

  @override
  List<Object?> get props => [
        savingId,
        reservations,
        totalReserved,
        currentAmount,
      ];

  /// Creates a copy with updated fields
  SavingsReserveSummary copyWith({
    String? savingId,
    List<ReserveVO>? reservations,
    double? totalReserved,
    double? currentAmount,
  }) {
    return SavingsReserveSummary(
      savingId: savingId ?? this.savingId,
      reservations: reservations ?? this.reservations,
      totalReserved: totalReserved ?? this.totalReserved,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }

  /// Converts to JSON map
  Map<String, dynamic> toJson() {
    return {
      'savingId': savingId,
      'reservations': reservations.map((r) => r.toJson()).toList(),
      'totalReserved': totalReserved,
      'currentAmount': currentAmount,
      'transferableAmount': transferableAmount,
      'commitmentTaskReserved': commitmentTaskReserved,
      'budgetPlanAllocationReserved': budgetPlanAllocationReserved,
      'hasReservations': hasReservations,
    };
  }

  /// Creates from JSON map
  factory SavingsReserveSummary.fromJson(Map<String, dynamic> json) {
    return SavingsReserveSummary(
      savingId: json['savingId'] as String,
      reservations: (json['reservations'] as List<dynamic>)
          .map((r) => ReserveVO.fromJson(r as Map<String, dynamic>))
          .toList(),
      totalReserved: json['totalReserved'] as double,
      currentAmount: json['currentAmount'] as double,
    );
  }
}
