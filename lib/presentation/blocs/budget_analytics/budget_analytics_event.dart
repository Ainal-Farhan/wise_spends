import 'package:equatable/equatable.dart';

/// Budget Analytics BLoC Events
abstract class BudgetAnalyticsEvent extends Equatable {
  const BudgetAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load analytics for a plan
class LoadPlanAnalytics extends BudgetAnalyticsEvent {
  final String planUuid;

  const LoadPlanAnalytics(this.planUuid);

  @override
  List<Object> get props => [planUuid];
}

/// Change analytics period
class ChangePeriod extends BudgetAnalyticsEvent {
  final AnalyticsPeriod period;

  const ChangePeriod(this.period);

  @override
  List<Object> get props => [period];
}

/// Analytics period enum
enum AnalyticsPeriod {
  week,
  month,
  year,
  all,
}
