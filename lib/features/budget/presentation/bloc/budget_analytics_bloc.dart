import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_analytics_event.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_analytics_state.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/i_budget_plan_repository.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_analytics.dart';

/// Budget Analytics BLoC — manages analytics data for the charts tab.
class BudgetAnalyticsBloc
    extends Bloc<BudgetAnalyticsEvent, BudgetAnalyticsState> {
  final IBudgetPlanRepository _repository;

  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.month;
  String? _currentPlanUuid;

  BudgetAnalyticsBloc(this._repository) : super(BudgetAnalyticsInitial()) {
    on<LoadPlanAnalytics>(_onLoadPlanAnalytics);
    on<ChangePeriod>(_onChangePeriod);
  }

  // ── Load analytics ─────────────────────────────────────────────────────────

  Future<void> _onLoadPlanAnalytics(
    LoadPlanAnalytics event,
    Emitter<BudgetAnalyticsState> emit,
  ) async {
    _currentPlanUuid = event.planUuid;
    emit(BudgetAnalyticsLoading());
    try {
      final analytics = await _repository.getPlanAnalytics(event.planUuid);
      emit(_toLoaded(_filterAnalytics(analytics, _currentPeriod)));
    } catch (e) {
      emit(BudgetAnalyticsError('Failed to load analytics: $e'));
    }
  }

  // ── Change period ──────────────────────────────────────────────────────────

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<BudgetAnalyticsState> emit,
  ) async {
    _currentPeriod = event.period;
    final uuid = _currentPlanUuid;
    if (uuid == null) return;

    // Keep existing data visible while reloading — avoids a jarring flash.
    if (state is! BudgetAnalyticsLoaded) emit(BudgetAnalyticsLoading());

    try {
      final analytics = await _repository.getPlanAnalytics(uuid);
      emit(_toLoaded(_filterAnalytics(analytics, _currentPeriod)));
    } catch (e) {
      emit(BudgetAnalyticsError('Failed to reload analytics: $e'));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Maps a [PlanAnalyticsData] to [BudgetAnalyticsLoaded].
  BudgetAnalyticsLoaded _toLoaded(PlanAnalyticsData data) {
    return BudgetAnalyticsLoaded(
      monthlyContributions: data.monthlyContributions,
      progressHistory: data.progressHistory,
      spendingByCategory: data.spendingByCategory,
      period: _currentPeriod,
      averageMonthlyDeposit: data.averageMonthlyDeposit,
      averageMonthlySpending: data.averageMonthlySpending,
      projectedCompletionLabel: data.projectedCompletionLabel,
    );
  }

  /// Returns [analytics] trimmed to the [period] window.
  /// Averages are recalculated over the trimmed window for consistency.
  PlanAnalyticsData _filterAnalytics(
    PlanAnalyticsData analytics,
    AnalyticsPeriod period,
  ) {
    final cutoff = _cutoffDate(period);
    if (cutoff == null) return analytics; // AnalyticsPeriod.all — no trimming

    final contributions = analytics.monthlyContributions.where((c) {
      final date = DateTime(c.year, c.month);
      return !date.isBefore(cutoff);
    }).toList();

    final snapshots = analytics.progressHistory
        .where((s) => !s.date.isBefore(cutoff))
        .toList();

    final months = contributions.length;
    final totalDeposits = contributions.fold<double>(
      0,
      (s, c) => s + c.deposits,
    );
    final totalSpending = contributions.fold<double>(
      0,
      (s, c) => s + c.spending,
    );

    return PlanAnalyticsData(
      monthlyContributions: contributions,
      progressHistory: snapshots,
      spendingByCategory: analytics.spendingByCategory,
      averageMonthlyDeposit: months > 0 ? totalDeposits / months : 0,
      averageMonthlySpending: months > 0 ? totalSpending / months : 0,
      projectedCompletionLabel: analytics.projectedCompletionLabel,
    );
  }

  DateTime? _cutoffDate(AnalyticsPeriod period) {
    final now = DateTime.now();
    return switch (period) {
      AnalyticsPeriod.week => now.subtract(const Duration(days: 7)),
      AnalyticsPeriod.month => DateTime(now.year, now.month - 1, now.day),
      AnalyticsPeriod.quarter => DateTime(now.year, now.month - 3, now.day),
      AnalyticsPeriod.year => DateTime(now.year - 1, now.month, now.day),
      AnalyticsPeriod.all => null,
    };
  }
}
