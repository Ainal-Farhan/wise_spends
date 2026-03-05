import 'package:equatable/equatable.dart';

/// Budget Plan Milestone Entity - sub-goal within a plan
class BudgetPlanMilestoneEntity extends Equatable {
  final int? id;
  final int planId;
  final String title;
  final double targetAmount;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;

  const BudgetPlanMilestoneEntity({
    this.id,
    required this.planId,
    required this.title,
    required this.targetAmount,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        planId,
        title,
        targetAmount,
        isCompleted,
        dueDate,
        completedAt,
      ];

  BudgetPlanMilestoneEntity copyWith({
    int? id,
    int? planId,
    String? title,
    double? targetAmount,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return BudgetPlanMilestoneEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
