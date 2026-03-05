import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';

/// Budget Plan Detail BLoC Events
abstract class BudgetPlanDetailEvent extends Equatable {
  const BudgetPlanDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load plan detail
class LoadPlanDetail extends BudgetPlanDetailEvent {
  final String uuid;

  const LoadPlanDetail(this.uuid);

  @override
  List<Object> get props => [uuid];
}

/// Add deposit to plan
class AddDeposit extends BudgetPlanDetailEvent {
  final double amount;
  final String? note;
  final String source;
  final DateTime depositDate;
  final int? linkedAccountId;

  const AddDeposit({
    required this.amount,
    this.note,
    this.source = 'manual',
    required this.depositDate,
    this.linkedAccountId,
  });

  @override
  List<Object?> get props => [
    amount,
    note,
    source,
    depositDate,
    linkedAccountId,
  ];
}

/// Add spending to plan
class AddSpending extends BudgetPlanDetailEvent {
  final double amount;
  final String? description;
  final String? vendor;
  final DateTime transactionDate;
  final String? receiptPath;

  const AddSpending({
    required this.amount,
    this.description,
    this.vendor,
    required this.transactionDate,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [amount, description, vendor, transactionDate, receiptPath];
}

/// Add milestone
class AddMilestoneEvent extends BudgetPlanDetailEvent {
  final String title;
  final double targetAmount;
  final DateTime? dueDate;

  const AddMilestoneEvent({
    required this.title,
    required this.targetAmount,
    this.dueDate,
  });

  @override
  List<Object?> get props => [title, targetAmount, dueDate];
}

/// Complete milestone
class CompleteMilestoneEvent extends BudgetPlanDetailEvent {
  final int milestoneId;

  const CompleteMilestoneEvent(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

/// Delete milestone
class DeleteMilestoneEvent extends BudgetPlanDetailEvent {
  final int milestoneId;

  const DeleteMilestoneEvent(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

/// Unlink account from plan
class UnlinkAccountEvent extends BudgetPlanDetailEvent {
  final int accountId;

  const UnlinkAccountEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}

/// Update plan status
class UpdatePlanStatusEvent extends BudgetPlanDetailEvent {
  final BudgetPlanStatus status;

  const UpdatePlanStatusEvent(this.status);

  @override
  List<Object> get props => [status];
}

/// Delete plan
class DeletePlanEvent extends BudgetPlanDetailEvent {
  final String uuid;

  const DeletePlanEvent(this.uuid);

  @override
  List<Object> get props => [uuid];
}

/// Refresh plan data
class RefreshPlanEvent extends BudgetPlanDetailEvent {}
