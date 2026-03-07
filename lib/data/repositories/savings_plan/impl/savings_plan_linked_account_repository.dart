import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_linked_account_repository.dart';

/// Savings Plan Linked Account Repository Implementation
class SavingsPlanLinkedAccountRepository
    extends ISavingsPlanLinkedAccountRepository {
  SavingsPlanLinkedAccountRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'SavingsPlanLinkedAccountTable';

  @override
  Stream<List<SvngPlnLinkedAccount>> watchByPlanId(String planId) {
    return (db.select(
      db.savingsPlanLinkedAccountTable,
    )..where((tbl) => tbl.planId.equals(planId))).watch();
  }

  @override
  Future<List<SvngPlnLinkedAccount>> getByPlanId(String planId) async {
    return (db.select(
      db.savingsPlanLinkedAccountTable,
    )..where((tbl) => tbl.planId.equals(planId))).get();
  }

  @override
  Future<void> deleteByPlanId(String planId) async {
    await (db.delete(
      db.savingsPlanLinkedAccountTable,
    )..where((tbl) => tbl.planId.equals(planId))).go();
  }
}
