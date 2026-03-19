import 'package:equatable/equatable.dart';

/// Plan Progress Snapshot - for charting progress over time
class PlanProgressSnapshot extends Equatable {
  final DateTime date;
  final double amount;
  final double targetAmount;
  final double progressPercentage;

  const PlanProgressSnapshot({
    required this.date,
    required this.amount,
    required this.targetAmount,
    required this.progressPercentage,
  });

  /// Get day index for charting (days from start)
  int get dayIndex =>
      date.difference(DateTime(date.year, date.month, 1)).inDays;

  @override
  List<Object?> get props => [date, amount, targetAmount, progressPercentage];
}

/// Monthly Contribution - for bar charts
class MonthlyContribution extends Equatable {
  final int year;
  final int month;
  final double deposits;
  final double spending;
  final double net;

  const MonthlyContribution({
    required this.year,
    required this.month,
    required this.deposits,
    required this.spending,
    required this.net,
  });

  /// Get month index (0-11)
  int get monthIndex => month - 1;

  /// Get month name
  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[monthIndex];
  }

  /// Get full month name
  String get monthFullName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[monthIndex];
  }

  @override
  List<Object?> get props => [year, month, deposits, spending, net];
}

/// Spending by Category - for donut charts
class SpendingByCategory extends Equatable {
  final String category;
  final double amount;
  final double percentage;
  final String? iconCode;

  const SpendingByCategory({
    required this.category,
    required this.amount,
    required this.percentage,
    this.iconCode,
  });

  @override
  List<Object?> get props => [category, amount, percentage, iconCode];
}

/// Plan Analytics Data - aggregated data for charts
class PlanAnalyticsData extends Equatable {
  final List<MonthlyContribution> monthlyContributions;
  final List<PlanProgressSnapshot> progressHistory;
  final List<SpendingByCategory> spendingByCategory;
  final double averageMonthlyDeposit;
  final double averageMonthlySpending;
  final double projectedCompletionMonths;
  final String projectedCompletionLabel;

  const PlanAnalyticsData({
    required this.monthlyContributions,
    required this.progressHistory,
    required this.spendingByCategory,
    required this.averageMonthlyDeposit,
    required this.averageMonthlySpending,
    this.projectedCompletionMonths = -1,
    required this.projectedCompletionLabel,
  });

  @override
  List<Object?> get props => [
    monthlyContributions,
    progressHistory,
    spendingByCategory,
    averageMonthlyDeposit,
    averageMonthlySpending,
    projectedCompletionMonths,
    projectedCompletionLabel,
  ];
}

// ─── Point-in-time balance snapshot ───────────────────────────────────────

class ProgressSnapshot {
  final DateTime date;

  /// Saved amount at this point in time.
  final double amount;

  const ProgressSnapshot({required this.date, required this.amount});
}

// ─── Spending broken down by category ─────────────────────────────────────

class CategorySpending {
  final String categoryName;
  final double amount;

  const CategorySpending({required this.categoryName, required this.amount});
}
