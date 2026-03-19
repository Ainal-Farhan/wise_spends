import 'package:equatable/equatable.dart';
import 'budget_plan_enums.dart';
import 'budget_plan_deposit_entity.dart';
import 'budget_plan_transaction_entity.dart';
import 'budget_plan_milestone_entity.dart';

/// Budget Plan Entity - represents a financial goal
class BudgetPlanEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final BudgetPlanCategory category;
  final double targetAmount;
  final double currentAmount;
  final double totalSpent;
  final double totalDeposited;
  final String currency;
  final DateTime startDate;
  final DateTime targetDate;
  final BudgetPlanStatus status;
  final String? iconCode;
  final String? colorHex;
  final List<BudgetPlanMilestoneEntity> milestones;
  final List<BudgetPlanDepositEntity> recentDeposits;
  final List<BudgetPlanTransactionEntity> recentTransactions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int fullyPaidItems;
  final int depositOnlyItems;
  final int outstandingItemCount;

  /// Total amount committed to items (sum of all item.totalCost)
  final double totalItemCommitment;

  /// Total deposit paid for items (sum of all item.depositPaid)
  final double totalItemDepositPaid;

  /// Total amount paid toward items excluding deposit (sum of all item.amountPaid)
  final double totalItemAmountPaid;

  /// Total outstanding amount for items (sum of all item.outstanding)
  final double totalItemOutstanding;

  const BudgetPlanEntity({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.totalSpent = 0.0,
    this.totalDeposited = 0.0,
    this.currency = 'MYR',
    required this.startDate,
    required this.targetDate,
    this.status = BudgetPlanStatus.active,
    this.iconCode,
    this.colorHex,
    this.milestones = const [],
    this.recentDeposits = const [],
    this.recentTransactions = const [],
    required this.createdAt,
    required this.updatedAt,
    this.totalItemCommitment = 0.0,
    this.totalItemDepositPaid = 0.0,
    this.totalItemAmountPaid = 0.0,
    this.totalItemOutstanding = 0.0,
    this.fullyPaidItems = 0,
    this.depositOnlyItems = 0,
    this.outstandingItemCount = 0,
  });

  /// Computed: Progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetAmount <= 0 || currentAmount < 0) return 0.0;
    final progress = currentAmount / targetAmount;
    // Handle potential infinity from very large numbers
    if (progress.isInfinite || progress.isNaN) return 1.0;
    return progress.clamp(0.0, 1.0);
  }

  /// Computed: Remaining amount to reach target
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    // Prevent negative remaining amount
    return remaining < 0 ? 0 : remaining;
  }

  /// Computed: Whether plan is over budget
  bool get isOverBudget => totalSpent > targetAmount;

  /// Computed: Days remaining until target date
  int get daysRemaining {
    final now = DateTime.now();
    // Handle case where target date is before start date
    if (targetDate.isBefore(startDate)) return 0;
    final days = targetDate.difference(now).inDays;
    return days < 0 ? 0 : days;
  }

  /// Computed: Whether target date has passed
  bool get isOverdue =>
      DateTime.now().isAfter(targetDate) && currentAmount < targetAmount;

  /// Computed: Total duration in days
  int get totalDuration {
    final duration = targetDate.difference(startDate).inDays;
    // Prevent negative duration
    return duration < 0 ? 0 : duration;
  }

  /// Computed: Elapsed duration in days
  int get elapsedDuration {
    final now = DateTime.now();
    // Handle case where start date is in the future
    if (now.isBefore(startDate)) return 0;
    final elapsed = now.difference(startDate).inDays;
    return elapsed < 0 ? 0 : elapsed;
  }

  /// Computed: Required monthly saving to reach target
  double get requiredMonthlySaving {
    if (remainingAmount <= 0) return 0.0;
    final days = daysRemaining;
    if (days <= 0) return remainingAmount; // Need to save all immediately
    final months = days / 30;
    // Prevent division by very small numbers
    if (months < 0.01) return remainingAmount;
    return remainingAmount / months;
  }

  /// Computed: Health status of the plan
  BudgetHealthStatus get healthStatus {
    if (progressPercentage >= 1.0) return BudgetHealthStatus.completed;
    if (isOverBudget) return BudgetHealthStatus.overBudget;

    // Check if on track: current savings pace vs required
    final totalMonths = totalDuration / 30;
    final elapsedMonths = elapsedDuration / 30;

    if (totalMonths <= 0 || totalMonths.isInfinite) {
      return BudgetHealthStatus.atRisk;
    }

    final expectedProgress = elapsedMonths / totalMonths;
    final actualProgress = progressPercentage;

    if (actualProgress >= expectedProgress * 0.9) {
      return BudgetHealthStatus.onTrack;
    } else if (actualProgress >= expectedProgress * 0.7) {
      return BudgetHealthStatus.slightlyBehind;
    } else {
      return BudgetHealthStatus.atRisk;
    }
  }

  /// Computed: Projected completion date in months
  double get projectedCompletionMonths {
    if (totalDeposited <= 0) return -1;
    final elapsedMonths = elapsedDuration / 30;
    // Prevent division by zero or negative
    if (elapsedMonths <= 0) return -1;
    final monthlyRate = totalDeposited / elapsedMonths;
    if (monthlyRate <= 0 || monthlyRate.isInfinite || monthlyRate.isNaN) {
      return -1;
    }
    return remainingAmount / monthlyRate;
  }

  /// Computed: Projected completion label
  String get projectedCompletionLabel {
    final months = projectedCompletionMonths;
    if (months < 0) return 'Insufficient data';

    final projectedDate = DateTime.now().add(
      Duration(days: (months * 30).round()),
    );
    final monthsUntil = projectedDate.difference(DateTime.now()).inDays ~/ 30;

    if (monthsUntil <= 0) return 'On track for this month';
    if (monthsUntil == 1) return 'On track for next month';
    return 'On track for ${_getMonthName(projectedDate.month)} ${projectedDate.year}';
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    targetAmount,
    currentAmount,
    totalSpent,
    totalDeposited,
    currency,
    startDate,
    targetDate,
    status,
    iconCode,
    colorHex,
    milestones,
    recentDeposits,
    recentTransactions,
    createdAt,
    updatedAt,
    totalItemCommitment,
    totalItemDepositPaid,
    totalItemAmountPaid,
    totalItemOutstanding,
    fullyPaidItems,
    depositOnlyItems,
    outstandingItemCount,
  ];

  BudgetPlanEntity copyWith({
    String? id,
    String? name,
    String? description,
    BudgetPlanCategory? category,
    double? targetAmount,
    double? currentAmount,
    double? totalSpent,
    double? totalDeposited,
    String? currency,
    DateTime? startDate,
    DateTime? targetDate,
    BudgetPlanStatus? status,
    String? iconCode,
    String? colorHex,
    List<BudgetPlanMilestoneEntity>? milestones,
    List<BudgetPlanDepositEntity>? recentDeposits,
    List<BudgetPlanTransactionEntity>? recentTransactions,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalItemCommitment,
    double? totalItemDepositPaid,
    double? totalItemAmountPaid,
    double? totalItemOutstanding,
    int? fullyPaidItems,
    int? depositOnlyItems,
    int? outstandingItemCount,
  }) {
    return BudgetPlanEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      totalSpent: totalSpent ?? this.totalSpent,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      milestones: milestones ?? this.milestones,
      recentDeposits: recentDeposits ?? this.recentDeposits,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalItemCommitment: totalItemCommitment ?? this.totalItemCommitment,
      totalItemDepositPaid: totalItemDepositPaid ?? this.totalItemDepositPaid,
      totalItemAmountPaid: totalItemAmountPaid ?? this.totalItemAmountPaid,
      totalItemOutstanding: totalItemOutstanding ?? this.totalItemOutstanding,
      fullyPaidItems: fullyPaidItems ?? this.fullyPaidItems,
      depositOnlyItems: depositOnlyItems ?? this.depositOnlyItems,
      outstandingItemCount: outstandingItemCount ?? this.outstandingItemCount,
    );
  }
}
