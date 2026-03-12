import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';

/// Budget Plan Detail BLoC Events
abstract class BudgetPlanDetailEvent extends Equatable {
  const BudgetPlanDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load plan detail
class LoadPlanDetail extends BudgetPlanDetailEvent {
  final String id;

  const LoadPlanDetail(this.id);

  @override
  List<Object> get props => [id];
}

/// Add deposit to plan
class AddDeposit extends BudgetPlanDetailEvent {
  final double amount;
  final String? note;
  final String source;
  final DateTime depositDate;
  final String? linkedAccountId;

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
  final String? linkedAccountId;

  const AddSpending({
    required this.amount,
    this.description,
    this.vendor,
    required this.transactionDate,
    this.receiptPath,
    this.linkedAccountId,
  });

  @override
  List<Object?> get props => [
    amount,
    description,
    vendor,
    transactionDate,
    receiptPath,
    linkedAccountId,
  ];
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
  final String milestoneId;

  const CompleteMilestoneEvent(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

/// Delete milestone
class DeleteMilestoneEvent extends BudgetPlanDetailEvent {
  final String milestoneId;

  const DeleteMilestoneEvent(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

/// Unlink account from plan
class UnlinkAccountEvent extends BudgetPlanDetailEvent {
  final String accountId;

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
  final String id;

  const DeletePlanEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// Refresh plan data
class RefreshPlanEvent extends BudgetPlanDetailEvent {}

class DeleteDeposit extends BudgetPlanDetailEvent {
  final String depositId;
  const DeleteDeposit(this.depositId);
}

class DeleteSpending extends BudgetPlanDetailEvent {
  final String transactionId;
  const DeleteSpending(this.transactionId);
}

class LinkAccountEvent extends BudgetPlanDetailEvent {
  final String accountId;
  final double allocatedAmount;
  const LinkAccountEvent({
    required this.accountId,
    required this.allocatedAmount,
  });
}
