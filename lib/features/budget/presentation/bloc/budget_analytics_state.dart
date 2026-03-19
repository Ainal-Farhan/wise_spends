import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_analytics.dart'
    show MonthlyContribution, PlanProgressSnapshot, SpendingByCategory;
import 'budget_analytics_event.dart';

// ─── States ────────────────────────────────────────────────────────────────

abstract class BudgetAnalyticsState extends Equatable {
  const BudgetAnalyticsState();

  @override
  List<Object?> get props => [];
}

class BudgetAnalyticsInitial extends BudgetAnalyticsState {}

class BudgetAnalyticsLoading extends BudgetAnalyticsState {}

class BudgetAnalyticsLoaded extends BudgetAnalyticsState {
  final List<MonthlyContribution> monthlyContributions;
  final List<PlanProgressSnapshot> progressHistory;
  final List<SpendingByCategory> spendingByCategory;
  final AnalyticsPeriod period;
  final double averageMonthlyDeposit;
  final double averageMonthlySpending;
  final String projectedCompletionLabel;

  const BudgetAnalyticsLoaded({
    required this.monthlyContributions,
    required this.progressHistory,
    required this.spendingByCategory,
    required this.period,
    required this.averageMonthlyDeposit,
    required this.averageMonthlySpending,
    required this.projectedCompletionLabel,
  });

  @override
  List<Object?> get props => [
    monthlyContributions,
    progressHistory,
    spendingByCategory,
    period,
    averageMonthlyDeposit,
    averageMonthlySpending,
    projectedCompletionLabel,
  ];
}

class BudgetAnalyticsError extends BudgetAnalyticsState {
  final String message;

  const BudgetAnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}
