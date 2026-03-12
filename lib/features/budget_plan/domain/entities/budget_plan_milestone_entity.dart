import 'package:equatable/equatable.dart';

/// Budget Plan Milestone Entity - sub-goal within a plan
class BudgetPlanMilestoneEntity extends Equatable {
  final String id;
  final String planId;
  final String title;
  final double targetAmount;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;

  const BudgetPlanMilestoneEntity({
    required this.id,
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
    String? id,
    String? planId,
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
