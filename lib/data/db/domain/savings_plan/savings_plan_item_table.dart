import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_table.dart';

/// Savings Plan Item table for tracking individual budget line items.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// Each item represents a line in the wedding budget (e.g., "Pelamin", "Makeup").
/// Related tables:
///   - [SavingsPlanItemTagTable] — optional tags for categorization
///   - [SavingsPlanDepositTable] — can link deposits to specific items
///   - [SavingsPlanSpendingTable] — can link spending to specific items
@DataClassName("${DomainTableConstant.savingsPlanTablePrefix}Item")
class SavingsPlanItemTable extends BaseEntityTable {
  /// FK to [SavingsPlanTable] — the plan this item belongs to.
  TextColumn get planId => text().references(SavingsPlanTable, #id)();

  /// Sort order for fractional indexing (allows inserting between items without renumbering).
  /// Start at 1000.0, increment by 1000.0. Insert between: average of neighbors.
  RealColumn get sortOrder => real().withDefault(const Constant(1000.0))();

  /// Item name/description (Perkara in Malay).
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Total cost for this item (Jumlah in Malay).
  RealColumn get totalCost => real().withDefault(const Constant(0.0))();

  /// Deposit amount paid (Deposit in Malay).
  RealColumn get depositPaid => real().withDefault(const Constant(0.0))();

  /// Total amount paid so far (Telah Bayar in Malay).
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();

  /// Optional notes/remarks (e.g., "hujung bulan 3 dapat RM2000").
  TextColumn get notes => text().nullable()();

  /// Whether this item is fully paid/completed.
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  /// Optional deadline for payment/completion of this item.
  DateTimeColumn get dueDate => dateTime().nullable()();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  @override
  List<Set<Column>> get uniqueKeys => [
    // Allow sorting within a plan
    {planId, sortOrder},
  ];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'planId': planId.name,
    'sortOrder': sortOrder.name,
    'name': name.name,
    'totalCost': totalCost.name,
    'depositPaid': depositPaid.name,
    'amountPaid': amountPaid.name,
    'notes': notes.name,
    'isCompleted': isCompleted.name,
    'dueDate': dueDate.name,
  };
}
