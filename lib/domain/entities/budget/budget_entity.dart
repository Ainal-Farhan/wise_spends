import 'package:equatable/equatable.dart';

/// Budget period enum
enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

/// Budget entity for tracking spending limits
class BudgetEntity extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final double limitAmount;
  final double spentAmount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    required this.limitAmount,
    this.spentAmount = 0,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        categoryName,
        categoryIcon,
        limitAmount,
        spentAmount,
        period,
        startDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Get percentage of budget used
  double get percentageUsed {
    if (limitAmount == 0) return 0;
    return (spentAmount / limitAmount) * 100;
  }

  /// Get remaining budget amount
  double get remainingAmount {
    return limitAmount - spentAmount;
  }

  /// Check if budget is exceeded
  bool get isExceeded => spentAmount > limitAmount;

  /// Check if budget is near limit (>85%)
  bool get isNearLimit => percentageUsed >= 85 && !isExceeded;

  BudgetEntity copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    double? limitAmount,
    double? spentAmount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
