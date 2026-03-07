import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_milestone_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Savings Plan Milestone Repository Interface
abstract class ISavingsPlanMilestoneRepository
    extends
        ICrudRepository<
          SavingsPlanMilestoneTable,
          $SavingsPlanMilestoneTableTable,
          SavingsPlanMilestoneTableCompanion,
          SvngPlnMilestone
        > {
  ISavingsPlanMilestoneRepository(AppDatabase db)
      : super(db, db.savingsPlanMilestoneTable);

  /// Watch all milestones for a plan
  Stream<List<SvngPlnMilestone>> watchByPlanId(String planId);

  /// Get all milestones for a plan
  Future<List<SvngPlnMilestone>> getByPlanId(String planId);

  /// Delete all milestones for a plan
  Future<void> deleteByPlanId(String planId);
}
