import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';

/// Savings Plan table for tracking financial goals over time.
///
/// Extends [BaseEntityTable] which provides:
///   - id          (TextColumn, primary key)
///   - createdBy
///   - lastModifiedBy
///   - dateUpdated
///
/// This table tracks savings goals with target amounts and deadlines.
/// Related tables:
///   - [SavingsPlanDepositTable] — money added to the plan
///   - [SavingsPlanSpendingTable] — money spent from the plan
///   - [SavingsPlanLinkedAccountTable] — linked savings accounts
///   - [SavingsPlanMilestoneTable] — sub-goals within the plan
@DataClassName("${DomainTableConstant.savingsPlanTablePrefix}SavingsPlan")
class SavingsPlanTable extends BaseEntityTable {
  /// Plan name (e.g., "Wedding Fund", "New House", "Family Trip").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Optional description of the goal.
  TextColumn get description => text().nullable()();

  /// Plan category: `wedding`, `house`, `travel`, `education`,
  /// `emergency`, `vehicle`, `medical`, `custom`.
  TextColumn get category => text()();

  /// Target amount to save.
  RealColumn get targetAmount => real()();

  /// Current saved amount (calculated from deposits minus spending).
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();

  /// Currency code (default: 'MYR').
  TextColumn get currency => text().withDefault(const Constant('MYR'))();

  /// When saving started.
  DateTimeColumn get startDate => dateTime()();

  /// Goal deadline.
  DateTimeColumn get targetDate => dateTime()();

  /// Plan status: `active`, `completed`, `paused`, `cancelled`.
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Optional icon codepoint for display.
  TextColumn get iconCode => text().nullable()();

  /// Optional custom color hex code.
  TextColumn get colorHex => text().nullable()();

  /// When this plan was first created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  @override
  List<Set<Column>> get uniqueKeys => [];

  // ---------------------------------------------------------------------------
  // Column map — used by base repository query helpers
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'name': name.name,
    'description': description.name,
    'category': category.name,
    'targetAmount': targetAmount.name,
    'currentAmount': currentAmount.name,
    'currency': currency.name,
    'startDate': startDate.name,
    'targetDate': targetDate.name,
    'status': status.name,
    'iconCode': iconCode.name,
    'colorHex': colorHex.name,
    'createdAt': createdAt.name,
  };
}
