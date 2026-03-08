import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_analytics.dart';
import 'budget_analytics_event.dart';
import 'budget_analytics_state.dart';

/// Budget Analytics BLoC — manages analytics data for the charts tab.
///
/// Fixes applied:
///   • [_onChangePeriod] now reloads data from the repository filtered to
///     the requested period window, instead of just swapping a label on the
///     existing state.
///   • The active [_currentPlanUuid] is cached so period changes know which
///     plan to re-query without requiring the event to carry the UUID again.
class BudgetAnalyticsBloc
    extends Bloc<BudgetAnalyticsEvent, BudgetAnalyticsState> {
  final IBudgetPlanRepository _repository;

  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.month;

  /// Cached UUID so [_onChangePeriod] can reload without an extra parameter.
  String? _currentPlanUuid;

  BudgetAnalyticsBloc(this._repository) : super(BudgetAnalyticsInitial()) {
    on<LoadPlanAnalytics>(_onLoadPlanAnalytics);
    on<ChangePeriod>(_onChangePeriod);
  }

  // ---------------------------------------------------------------------------
  // Load analytics for a plan
  // ---------------------------------------------------------------------------

  Future<void> _onLoadPlanAnalytics(
    LoadPlanAnalytics event,
    Emitter<BudgetAnalyticsState> emit,
  ) async {
    _currentPlanUuid = event.planUuid;
    emit(BudgetAnalyticsLoading());
    try {
      final analytics = await _repository.getPlanAnalytics(event.planUuid);
      final filtered = _filterAnalytics(analytics, _currentPeriod);

      emit(
        BudgetAnalyticsLoaded(
          monthlyContributions: filtered.monthlyContributions,
          progressHistory: filtered.progressHistory,
          spendingByCategory: filtered.spendingByCategory,
          period: _currentPeriod,
          averageMonthlyDeposit: filtered.averageMonthlyDeposit,
          averageMonthlySpending: filtered.averageMonthlySpending,
          projectedCompletionLabel: filtered.projectedCompletionLabel,
        ),
      );
    } catch (e) {
      emit(BudgetAnalyticsError('Failed to load analytics: ${e.toString()}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Change analytics period — reloads real data for the new window
  // ---------------------------------------------------------------------------

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<BudgetAnalyticsState> emit,
  ) async {
    _currentPeriod = event.period;

    final uuid = _currentPlanUuid;
    if (uuid == null) return;

    // Show loading only if we don't already have data to avoid a jarring flash.
    if (state is! BudgetAnalyticsLoaded) {
      emit(BudgetAnalyticsLoading());
    }

    try {
      final analytics = await _repository.getPlanAnalytics(uuid);
      final filtered = _filterAnalytics(analytics, _currentPeriod);

      emit(
        BudgetAnalyticsLoaded(
          monthlyContributions: filtered.monthlyContributions,
          progressHistory: filtered.progressHistory,
          spendingByCategory: filtered.spendingByCategory,
          period: _currentPeriod,
          averageMonthlyDeposit: filtered.averageMonthlyDeposit,
          averageMonthlySpending: filtered.averageMonthlySpending,
          projectedCompletionLabel: filtered.projectedCompletionLabel,
        ),
      );
    } catch (e) {
      emit(BudgetAnalyticsError('Failed to reload analytics: ${e.toString()}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Helper — trim analytics data to the requested period window
  // ---------------------------------------------------------------------------

  /// Returns a copy of [analytics] with contributions and snapshots trimmed
  /// to the window defined by [period].  Averages are recalculated over the
  /// trimmed window so the stats stay consistent.
  PlanAnalyticsData _filterAnalytics(
    PlanAnalyticsData analytics,
    AnalyticsPeriod period,
  ) {
    final cutoff = _cutoffDate(period);
    if (cutoff == null) return analytics; // AnalyticsPeriod.all — no trimming

    final contributions = analytics.monthlyContributions.where((c) {
      final date = DateTime(c.year, c.month);
      return date.isAfter(cutoff) || date.isAtSameMomentAs(cutoff);
    }).toList();

    final snapshots = analytics.progressHistory
        .where((s) => s.date.isAfter(cutoff) || s.date.isAtSameMomentAs(cutoff))
        .toList();

    // Recalculate averages over the trimmed window.
    final months = contributions.length;
    final totalDeposits = contributions.fold<double>(
      0,
      (s, c) => s + c.deposits,
    );
    final totalSpending = contributions.fold<double>(
      0,
      (s, c) => s + c.spending,
    );
    final avgDeposit = months > 0 ? totalDeposits / months : 0.0;
    final avgSpending = months > 0 ? totalSpending / months : 0.0;

    return PlanAnalyticsData(
      monthlyContributions: contributions,
      progressHistory: snapshots,
      spendingByCategory: analytics.spendingByCategory,
      averageMonthlyDeposit: avgDeposit,
      averageMonthlySpending: avgSpending,
      projectedCompletionLabel: analytics.projectedCompletionLabel,
    );
  }

  /// Returns the earliest [DateTime] to include for the given [period],
  /// or null for [AnalyticsPeriod.all].
  DateTime? _cutoffDate(AnalyticsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case AnalyticsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.month:
        return DateTime(now.year, now.month - 1, now.day);
      case AnalyticsPeriod.quarter:
        return DateTime(now.year, now.month - 3, now.day);
      case AnalyticsPeriod.year:
        return DateTime(now.year - 1, now.month, now.day);
      case AnalyticsPeriod.all:
        return null;
    }
  }
}
