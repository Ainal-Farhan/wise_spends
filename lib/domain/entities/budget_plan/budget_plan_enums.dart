/// Budget Plan Category enum
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

/// Budget Plan Status enum
enum BudgetPlanStatus { active, completed, paused, cancelled }

/// Budget Health Status enum
enum BudgetHealthStatus {
  onTrack,
  slightlyBehind,
  atRisk,
  overBudget,
  completed,
}

/// Extension to get display name for category
extension BudgetPlanCategoryExtension on BudgetPlanCategory {
  String get displayName {
    switch (this) {
      case BudgetPlanCategory.wedding:
        return 'Wedding';
      case BudgetPlanCategory.house:
        return 'House';
      case BudgetPlanCategory.travel:
        return 'Travel';
      case BudgetPlanCategory.education:
        return 'Education';
      case BudgetPlanCategory.emergency:
        return 'Emergency';
      case BudgetPlanCategory.vehicle:
        return 'Vehicle';
      case BudgetPlanCategory.medical:
        return 'Medical';
      case BudgetPlanCategory.custom:
        return 'Custom';
    }
  }

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
        return '🎯';
    }
  }

  static BudgetPlanCategory fromString(String value) {
    return BudgetPlanCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => BudgetPlanCategory.custom,
    );
  }
}

/// Extension to get display name for status
extension BudgetPlanStatusExtension on BudgetPlanStatus {
  String get displayName {
    switch (this) {
      case BudgetPlanStatus.active:
        return 'Active';
      case BudgetPlanStatus.completed:
        return 'Completed';
      case BudgetPlanStatus.paused:
        return 'Paused';
      case BudgetPlanStatus.cancelled:
        return 'Cancelled';
    }
  }

  static BudgetPlanStatus fromString(String value) {
    return BudgetPlanStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => BudgetPlanStatus.active,
    );
  }
}

/// Extension to get display name for health status
extension BudgetHealthStatusExtension on BudgetHealthStatus {
  String get displayName {
    switch (this) {
      case BudgetHealthStatus.onTrack:
        return 'On Track';
      case BudgetHealthStatus.slightlyBehind:
        return 'Slightly Behind';
      case BudgetHealthStatus.atRisk:
        return 'At Risk';
      case BudgetHealthStatus.overBudget:
        return 'Over Budget';
      case BudgetHealthStatus.completed:
        return 'Completed';
    }
  }

  static BudgetHealthStatus fromString(String value) {
    return BudgetHealthStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase().replaceAll(' ', ''),
      orElse: () => BudgetHealthStatus.onTrack,
    );
  }
}
