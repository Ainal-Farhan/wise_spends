import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';
import 'budget_analytics_event.dart';
import 'budget_analytics_state.dart';

/// Budget Analytics BLoC - manages analytics data for charts
class BudgetAnalyticsBloc
    extends Bloc<BudgetAnalyticsEvent, BudgetAnalyticsState> {
  final IBudgetPlanRepository _repository;
  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.month;

  BudgetAnalyticsBloc(this._repository) : super(BudgetAnalyticsInitial()) {
    on<LoadPlanAnalytics>(_onLoadPlanAnalytics);
    on<ChangePeriod>(_onChangePeriod);
  }

  /// Load analytics for a plan
  Future<void> _onLoadPlanAnalytics(
    LoadPlanAnalytics event,
    Emitter<BudgetAnalyticsState> emit,
  ) async {
    emit(BudgetAnalyticsLoading());
    try {
      final analytics = await _repository.getPlanAnalytics(event.planUuid);

      emit(
        BudgetAnalyticsLoaded(
          monthlyContributions: analytics.monthlyContributions,
          progressHistory: analytics.progressHistory,
          spendingByCategory: analytics.spendingByCategory,
          period: _currentPeriod,
          averageMonthlyDeposit: analytics.averageMonthlyDeposit,
          averageMonthlySpending: analytics.averageMonthlySpending,
          projectedCompletionLabel: analytics.projectedCompletionLabel,
        ),
      );
    } catch (e) {
      emit(BudgetAnalyticsError('Failed to load analytics: ${e.toString()}'));
    }
  }

  /// Change analytics period
  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<BudgetAnalyticsState> emit,
  ) async {
    _currentPeriod = event.period;

    if (state is BudgetAnalyticsLoaded) {
      final currentState = state as BudgetAnalyticsLoaded;
      emit(
        currentState.copyWith(
          period: _currentPeriod,
          // In a real implementation, we'd reload data for the new period
        ),
      );
    }
  }
}
