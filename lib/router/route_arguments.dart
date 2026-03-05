/// Typed route arguments for WiseSpends app
/// Using strongly typed arguments instead of `Map<String, dynamic>`

library;

import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Base class for all route arguments
abstract class RouteArguments {
  const RouteArguments();
}

/// Arguments for Add Transaction screen
class AddTransactionArgs extends RouteArguments {
  final TransactionType? preselectedType;

  const AddTransactionArgs({this.preselectedType});
}

/// Arguments for Transaction Detail screen
class TransactionDetailArgs extends RouteArguments {
  final String transactionId;

  const TransactionDetailArgs(this.transactionId);
}

/// Arguments for Edit Transaction screen
class EditTransactionArgs extends RouteArguments {
  final String transactionId;

  const EditTransactionArgs(this.transactionId);
}

/// Arguments for Category List screen
class CategoryListArgs extends RouteArguments {
  final TransactionType? filterByType;
  final bool allowSelection;
  final Function(String categoryId)? onCategorySelected;

  const CategoryListArgs({
    this.filterByType,
    this.allowSelection = false,
    this.onCategorySelected,
  });
}

/// Arguments for Budget Detail screen
class BudgetDetailArgs extends RouteArguments {
  final String budgetId;

  const BudgetDetailArgs(this.budgetId);
}

/// Arguments for Create Budget screen
class CreateBudgetArgs extends RouteArguments {
  final String? preselectedCategoryId;

  const CreateBudgetArgs({this.preselectedCategoryId});
}

/// Arguments for Transaction History screen
class TransactionHistoryArgs extends RouteArguments {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? filterByType;
  final String? filterByCategory;

  const TransactionHistoryArgs({
    this.startDate,
    this.endDate,
    this.filterByType,
    this.filterByCategory,
  });
}

/// Arguments for Reports/Analytics screen
class ReportsArgs extends RouteArguments {
  final ReportPeriod period;

  const ReportsArgs({this.period = ReportPeriod.month});
}

/// Report period enum
enum ReportPeriod {
  week,
  month,
  year,
}
