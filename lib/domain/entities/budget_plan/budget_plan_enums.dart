import 'package:wise_spends/core/config/localization_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Budget Plan Category
enum BudgetPlanCategory {
  wedding,
  house,
  travel,
  education,
  emergency,
  vehicle,
  medical,
  custom,
}

/// Budget Plan Status
enum BudgetPlanStatus { active, completed, paused, cancelled }

/// Budget Health Status
enum BudgetHealthStatus {
  onTrack,
  slightlyBehind,
  atRisk,
  overBudget,
  completed,
}

/// Analytics Period
enum AnalyticsPeriod { week, month, quarter, year, all }

// ─────────────────────────────────────────────────────────────────────────────
// Extensions
// ─────────────────────────────────────────────────────────────────────────────

extension BudgetPlanCategoryX on BudgetPlanCategory {
  /// Emoji icon used as the category avatar in cards and chips.
  String get iconCode {
    switch (this) {
      case BudgetPlanCategory.wedding:
        return '💍';
      case BudgetPlanCategory.house:
        return '🏠';
      case BudgetPlanCategory.travel:
        return '✈️';
      case BudgetPlanCategory.education:
        return '🎓';
      case BudgetPlanCategory.emergency:
        return '🚨';
      case BudgetPlanCategory.vehicle:
        return '🚗';
      case BudgetPlanCategory.medical:
        return '🏥';
      case BudgetPlanCategory.custom:
        return '📦';
    }
  }

  /// Localised display name shown in cards, chips, and the overview header.
  String get displayName {
    switch (this) {
      case BudgetPlanCategory.wedding:
        return 'budget_plans.cat_wedding'.tr;
      case BudgetPlanCategory.house:
        return 'budget_plans.cat_house'.tr;
      case BudgetPlanCategory.travel:
        return 'budget_plans.cat_travel'.tr;
      case BudgetPlanCategory.education:
        return 'budget_plans.cat_education'.tr;
      case BudgetPlanCategory.emergency:
        return 'budget_plans.cat_emergency'.tr;
      case BudgetPlanCategory.vehicle:
        return 'budget_plans.cat_vehicle'.tr;
      case BudgetPlanCategory.medical:
        return 'budget_plans.cat_medical'.tr;
      case BudgetPlanCategory.custom:
        return 'budget_plans.cat_custom'.tr;
    }
  }
}

extension BudgetPlanStatusX on BudgetPlanStatus {
  String get displayName {
    switch (this) {
      case BudgetPlanStatus.active:
        return 'budget_plans.status_active'.tr;
      case BudgetPlanStatus.completed:
        return 'budget_plans.status_completed'.tr;
      case BudgetPlanStatus.paused:
        return 'budget_plans.status_paused'.tr;
      case BudgetPlanStatus.cancelled:
        return 'budget_plans.status_cancelled'.tr;
    }
  }
}

extension BudgetHealthStatusX on BudgetHealthStatus {
  String get displayName {
    switch (this) {
      case BudgetHealthStatus.onTrack:
        return 'budget_plans.health_on_track'.tr;
      case BudgetHealthStatus.slightlyBehind:
        return 'budget_plans.health_slightly_behind'.tr;
      case BudgetHealthStatus.atRisk:
        return 'budget_plans.health_at_risk'.tr;
      case BudgetHealthStatus.overBudget:
        return 'budget_plans.health_over_budget'.tr;
      case BudgetHealthStatus.completed:
        return 'budget_plans.health_completed'.tr;
    }
  }
}

extension AnalyticsPeriodX on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.week:
        return 'budget_plans.period_week'.tr;
      case AnalyticsPeriod.month:
        return 'budget_plans.period_month'.tr;
      case AnalyticsPeriod.quarter:
        return 'budget_plans.period_quarter'.tr;
      case AnalyticsPeriod.year:
        return 'budget_plans.period_year'.tr;
      case AnalyticsPeriod.all:
        return 'budget_plans.period_all'.tr;
    }
  }
}
