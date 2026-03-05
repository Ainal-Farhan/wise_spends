import 'package:drift/drift.dart';

/// Budget Plans table - stores financial goals
class BudgetPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // wedding, house, travel, education, emergency, vehicle, medical, custom
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('MYR'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, completed, paused, cancelled
  TextColumn get iconCode => text().nullable()();
  TextColumn get colorHex => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {uuid},
      ];
}

/// Budget Plan Deposits - money saved toward the goal
class BudgetPlanDeposits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36)();
  IntColumn get planId => integer().references(BudgetPlans, #id)();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  TextColumn get source => text().nullable()(); // manual, linked_account, salary, bonus, other
  DateTimeColumn get depositDate => dateTime()();
  IntColumn get linkedAccountId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Budget Plan Transactions - money spent from the plan
class BudgetPlanTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36)();
  IntColumn get planId => integer().references(BudgetPlans, #id)();
  IntColumn get transactionId => integer().nullable()();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  TextColumn get vendor => text().nullable()();
  TextColumn get receiptImagePath => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Budget Plan Linked Accounts - saving accounts contributing to plan
class BudgetPlanLinkedAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(BudgetPlans, #id)();
  IntColumn get accountId => integer()();
  RealColumn get allocatedPercentage => real().nullable()();
  DateTimeColumn get linkedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Budget Plan Milestones - optional sub-goals
class BudgetPlanMilestones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(BudgetPlans, #id)();
  TextColumn get title => text()();
  RealColumn get targetAmount => real()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}
