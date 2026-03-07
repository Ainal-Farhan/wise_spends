import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_deposit_repository.dart';

/// Savings Plan Deposit Repository Implementation
class SavingsPlanDepositRepository extends ISavingsPlanDepositRepository {
  SavingsPlanDepositRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'SavingsPlanDepositTable';

  @override
  Stream<List<SvngPlnDeposit>> watchByPlanId(String planId) {
    return (db.select(
      db.savingsPlanDepositTable,
    )..where((tbl) => tbl.planId.equals(planId))).watch();
  }

  @override
  Future<List<SvngPlnDeposit>> getByPlanId(String planId) async {
    return (db.select(
      db.savingsPlanDepositTable,
    )..where((tbl) => tbl.planId.equals(planId))).get();
  }

  @override
  Future<void> deleteByPlanId(String planId) async {
    await (db.delete(
      db.savingsPlanDepositTable,
    )..where((tbl) => tbl.planId.equals(planId))).go();
  }
}
