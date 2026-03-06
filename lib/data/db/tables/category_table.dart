import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';

/// Category table for transaction categories.
///
/// Extends [BaseEntityTable] which already provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// This table does NOT redeclare [id] — doing so causes a duplicate-column
/// Drift compile error.
@DataClassName("${DomainTableConstant.transactionTablePrefix}Category")
class CategoryTable extends BaseEntityTable {
  /// Display name shown in the UI and used for deduplication via [uniqueKeys].
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Icon identifier passed to [CategoryIconMapper].
  /// Stores the codepoint string (e.g. 'e318') rather than the int so it
  /// round-trips cleanly through JSON and the DB without casting.
  TextColumn get iconCodePoint => text()();

  /// Font family for the icon — defaults to MaterialIcons.
  TextColumn get iconFontFamily =>
      text().withDefault(const Constant('MaterialIcons'))();

  /// True when this category applies to income transactions.
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();

  /// True when this category applies to expense transactions.
  BoolColumn get isExpense => boolean().withDefault(const Constant(false))();

  /// Controls display order in the category grid.
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  /// Soft-delete flag — inactive categories are hidden from pickers
  /// but kept so existing transactions retain their category reference.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// When this category was first created. Separate from [dateUpdated]
  /// (provided by [BaseEntityTable]) which tracks the last modification.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  /// Category names must be unique — prevents duplicate "Food & Dining" etc.
  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
  ];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'name': name.name,
    'iconCodePoint': iconCodePoint.name,
    'iconFontFamily': iconFontFamily.name,
    'isIncome': isIncome.name,
    'isExpense': isExpense.name,
    'orderIndex': orderIndex.name,
    'isActive': isActive.name,
    'createdAt': createdAt.name,
  };
}
