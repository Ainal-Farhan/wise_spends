import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_deposit_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_transaction_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_milestone_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/linked_account_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_analytics.dart';

/// Budget Plan Detail BLoC States
abstract class BudgetPlanDetailState extends Equatable {
  const BudgetPlanDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BudgetPlanDetailInitial extends BudgetPlanDetailState {}

/// Loading state
class BudgetPlanDetailLoading extends BudgetPlanDetailState {}

/// Plan detail loaded
class BudgetPlanDetailLoaded extends BudgetPlanDetailState {
  final BudgetPlanEntity plan;
  final List<BudgetPlanDepositEntity> deposits;
  final List<BudgetPlanTransactionEntity> transactions;
  final List<BudgetPlanMilestoneEntity> milestones;
  final List<LinkedAccountSummaryEntity> linkedAccounts;
  final PlanAnalyticsData? analytics;

  const BudgetPlanDetailLoaded({
    required this.plan,
    this.deposits = const [],
    this.transactions = const [],
    this.milestones = const [],
    this.linkedAccounts = const [],
    this.analytics,
  });

  @override
  List<Object?> get props => [plan, deposits, transactions, milestones, linkedAccounts, analytics];

  BudgetPlanDetailLoaded copyWith({
    BudgetPlanEntity? plan,
    List<BudgetPlanDepositEntity>? deposits,
    List<BudgetPlanTransactionEntity>? transactions,
    List<BudgetPlanMilestoneEntity>? milestones,
    List<LinkedAccountSummaryEntity>? linkedAccounts,
    PlanAnalyticsData? analytics,
  }) {
    return BudgetPlanDetailLoaded(
      plan: plan ?? this.plan,
      deposits: deposits ?? this.deposits,
      transactions: transactions ?? this.transactions,
      milestones: milestones ?? this.milestones,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      analytics: analytics ?? this.analytics,
    );
  }
}

/// Error state
class BudgetPlanDetailError extends BudgetPlanDetailState {
  final String message;

  const BudgetPlanDetailError(this.message);

  @override
  List<Object> get props => [message];
}

/// Plan not found
class BudgetPlanNotFound extends BudgetPlanDetailState {}

/// Deposit added success
class DepositAdded extends BudgetPlanDetailState {
  final BudgetPlanDepositEntity deposit;

  const DepositAdded(this.deposit);

  @override
  List<Object> get props => [deposit];
}

/// Spending added success
class SpendingAdded extends BudgetPlanDetailState {
  final BudgetPlanTransactionEntity transaction;

  const SpendingAdded(this.transaction);

  @override
  List<Object> get props => [transaction];
}

/// Milestone added success
class MilestoneAdded extends BudgetPlanDetailState {
  final BudgetPlanMilestoneEntity milestone;

  const MilestoneAdded(this.milestone);

  @override
  List<Object> get props => [milestone];
}

/// Milestone deleted success
class MilestoneDeleted extends BudgetPlanDetailState {
  final String milestoneId;

  const MilestoneDeleted(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

/// Plan deleted success
class PlanDeleted extends BudgetPlanDetailState {
  final String uuid;

  const PlanDeleted(this.uuid);

  @override
  List<Object> get props => [uuid];
}
