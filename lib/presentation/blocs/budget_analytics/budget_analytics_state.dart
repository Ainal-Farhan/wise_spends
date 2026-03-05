import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_analytics.dart';
import 'budget_analytics_event.dart';

/// Budget Analytics BLoC States
abstract class BudgetAnalyticsState extends Equatable {
  const BudgetAnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BudgetAnalyticsInitial extends BudgetAnalyticsState {}

/// Loading state
class BudgetAnalyticsLoading extends BudgetAnalyticsState {}

/// Analytics loaded
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
    this.period = AnalyticsPeriod.month,
    this.averageMonthlyDeposit = 0,
    this.averageMonthlySpending = 0,
    this.projectedCompletionLabel = 'Insufficient data',
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

  BudgetAnalyticsLoaded copyWith({
    List<MonthlyContribution>? monthlyContributions,
    List<PlanProgressSnapshot>? progressHistory,
    List<SpendingByCategory>? spendingByCategory,
    AnalyticsPeriod? period,
    double? averageMonthlyDeposit,
    double? averageMonthlySpending,
    String? projectedCompletionLabel,
  }) {
    return BudgetAnalyticsLoaded(
      monthlyContributions: monthlyContributions ?? this.monthlyContributions,
      progressHistory: progressHistory ?? this.progressHistory,
      spendingByCategory: spendingByCategory ?? this.spendingByCategory,
      period: period ?? this.period,
      averageMonthlyDeposit: averageMonthlyDeposit ?? this.averageMonthlyDeposit,
      averageMonthlySpending: averageMonthlySpending ?? this.averageMonthlySpending,
      projectedCompletionLabel: projectedCompletionLabel ?? this.projectedCompletionLabel,
    );
  }
}

/// Error state
class BudgetAnalyticsError extends BudgetAnalyticsState {
  final String message;

  const BudgetAnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}
