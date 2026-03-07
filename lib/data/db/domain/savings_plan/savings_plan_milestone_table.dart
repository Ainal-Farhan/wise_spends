import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_table.dart';

/// Savings Plan Milestone table for tracking sub-goals within a savings plan.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// Milestones break large goals into smaller, achievable targets.
@DataClassName("${DomainTableConstant.savingsPlanTablePrefix}Milestone")
class SavingsPlanMilestoneTable extends BaseEntityTable {
  /// FK to [SavingsPlanTable] — the plan this milestone belongs to.
  TextColumn get planId => text().references(SavingsPlanTable, #id)();

  /// Milestone title (e.g., "50% Complete", "First $1000").
  TextColumn get title => text()();

  /// Target amount for this milestone.
  RealColumn get targetAmount => real()();

  /// Whether the milestone has been achieved.
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  /// Optional deadline for this milestone.
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// When the milestone was completed.
  DateTimeColumn get completedAt => dateTime().nullable()();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  @override
  List<Set<Column>> get uniqueKeys => [
    // Prevent duplicate milestone titles within the same plan
    {planId, title},
  ];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'planId': planId.name,
    'title': title.name,
    'targetAmount': targetAmount.name,
    'isCompleted': isCompleted.name,
    'dueDate': dueDate.name,
    'completedAt': completedAt.name,
  };
}
