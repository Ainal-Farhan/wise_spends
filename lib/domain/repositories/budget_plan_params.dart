import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';

/// Parameters for creating a budget plan
class CreateBudgetPlanParams extends Equatable {
  final String name;
  final String? description;
  final BudgetPlanCategory category;
  final double targetAmount;
  final String currency;
  final DateTime startDate;
  final DateTime targetDate;
  final String? iconCode;
  final String? colorHex;
  final List<CreateMilestoneParams>? milestones;

  const CreateBudgetPlanParams({
    required this.name,
    this.description,
    required this.category,
    required this.targetAmount,
    this.currency = 'MYR',
    required this.startDate,
    required this.targetDate,
    this.iconCode,
    this.colorHex,
    this.milestones,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        category,
        targetAmount,
        currency,
        startDate,
        targetDate,
        iconCode,
        colorHex,
        milestones,
      ];
}

/// Parameters for updating a budget plan
class UpdateBudgetPlanParams extends Equatable {
  final String? name;
  final String? description;
  final BudgetPlanCategory? category;
  final double? targetAmount;
  final DateTime? targetDate;
  final String? iconCode;
  final String? colorHex;

  const UpdateBudgetPlanParams({
    this.name,
    this.description,
    this.category,
    this.targetAmount,
    this.targetDate,
    this.iconCode,
    this.colorHex,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        category,
        targetAmount,
        targetDate,
        iconCode,
        colorHex,
      ];
}

/// Parameters for adding a deposit
class AddDepositParams extends Equatable {
  final double amount;
  final String? note;
  final String source;
  final DateTime depositDate;
  final String? linkedAccountId;

  const AddDepositParams({
    required this.amount,
    this.note,
    this.source = 'manual',
    required this.depositDate,
    this.linkedAccountId,
  });

  @override
  List<Object?> get props => [
        amount,
        note,
        source,
        depositDate,
        linkedAccountId,
      ];
}

/// Parameters for adding a spending transaction
class AddPlanTransactionParams extends Equatable {
  final double amount;
  final String? description;
  final String? vendor;
  final String? receiptImagePath;
  final DateTime transactionDate;
  final bool linkToMainTransaction;

  const AddPlanTransactionParams({
    required this.amount,
    this.description,
    this.vendor,
    this.receiptImagePath,
    required this.transactionDate,
    this.linkToMainTransaction = false,
  });

  @override
  List<Object?> get props => [
        amount,
        description,
        vendor,
        receiptImagePath,
        transactionDate,
        linkToMainTransaction,
      ];
}

/// Parameters for creating a milestone
class CreateMilestoneParams extends Equatable {
  final String title;
  final double targetAmount;
  final DateTime? dueDate;

  const CreateMilestoneParams({
    required this.title,
    required this.targetAmount,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
        title,
        targetAmount,
        dueDate,
      ];
}
