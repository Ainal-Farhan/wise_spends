import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_milestone_repository.dart';

/// Savings Plan Milestone Repository Implementation
class SavingsPlanMilestoneRepository extends ISavingsPlanMilestoneRepository {
  SavingsPlanMilestoneRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'SavingsPlanMilestoneTable';

  @override
  Stream<List<SvngPlnMilestone>> watchByPlanId(String planId) {
    return (db.select(
      db.savingsPlanMilestoneTable,
    )..where((tbl) => tbl.planId.equals(planId))).watch();
  }

  @override
  Future<List<SvngPlnMilestone>> getByPlanId(String planId) async {
    return (db.select(
      db.savingsPlanMilestoneTable,
    )..where((tbl) => tbl.planId.equals(planId))).get();
  }

  @override
  Future<void> deleteByPlanId(String planId) async {
    await (db.delete(
      db.savingsPlanMilestoneTable,
    )..where((tbl) => tbl.planId.equals(planId))).go();
  }

  @override
  SvngPlnMilestone fromJson(Map<String, dynamic> json) =>
      SvngPlnMilestone.fromJson(json);
}
