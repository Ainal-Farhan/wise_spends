import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_spending_repository.dart';

/// Savings Plan Spending Repository Implementation
class SavingsPlanSpendingRepository extends ISavingsPlanSpendingRepository {
  SavingsPlanSpendingRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'SavingsPlanSpendingTable';

  @override
  Stream<List<SvngPlnSpending>> watchByPlanId(String planId) {
    return (db.select(
      db.savingsPlanSpendingTable,
    )..where((tbl) => tbl.planId.equals(planId))).watch();
  }

  @override
  Future<List<SvngPlnSpending>> getByPlanId(String planId) async {
    return (db.select(
      db.savingsPlanSpendingTable,
    )..where((tbl) => tbl.planId.equals(planId))).get();
  }

  @override
  Future<void> deleteByPlanId(String planId) async {
    await (db.delete(
      db.savingsPlanSpendingTable,
    )..where((tbl) => tbl.planId.equals(planId))).go();
  }
}
