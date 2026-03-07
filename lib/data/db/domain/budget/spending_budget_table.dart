import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/transaction/category_table.dart';

/// Spending Budget table for tracking spending limits per category.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// This table tracks how much has been spent against a defined limit
/// within a specific time period (daily, weekly, monthly, yearly).
@DataClassName("${DomainTableConstant.budgetTablePrefix}SpendingBudget")
class SpendingBudgetTable extends BaseEntityTable {
  /// Display name for the budget (e.g., "Groceries Budget").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// FK to [CategoryTable] — the spending category this budget applies to.
  TextColumn get categoryId => text().references(CategoryTable, #id)();

  /// Maximum allowed spending amount for the period.
  RealColumn get limitAmount => real()();

  /// Current spent amount within the period.
  RealColumn get spentAmount => real().withDefault(const Constant(0.0))();

  /// Budget period: `daily`, `weekly`, `monthly`, `yearly`.
  TextColumn get period => text()();

  /// When the current budget period starts.
  DateTimeColumn get startDate => dateTime()();

  /// When the current budget period ends. Null for one-time budgets.
  DateTimeColumn get endDate => dateTime().nullable()();

  /// Whether the budget is currently active.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// When this budget was first created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  @override
  List<Set<Column>> get uniqueKeys => [
    // Prevent duplicate budgets for the same category and period
    {categoryId, period, startDate},
  ];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'name': name.name,
    'categoryId': categoryId.name,
    'limitAmount': limitAmount.name,
    'spentAmount': spentAmount.name,
    'period': period.name,
    'startDate': startDate.name,
    'endDate': endDate.name,
    'isActive': isActive.name,
    'createdAt': createdAt.name,
  };
}
