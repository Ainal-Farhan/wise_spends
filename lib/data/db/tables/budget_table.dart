import 'package:drift/drift.dart';

/// Budget table for tracking spending limits
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text().nullable()();
  TextColumn get categoryIcon => text().nullable()();
  RealColumn get limitAmount => real()();
  RealColumn get spentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get period => text()(); // daily, weekly, monthly, yearly
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {id},
      ];
}
