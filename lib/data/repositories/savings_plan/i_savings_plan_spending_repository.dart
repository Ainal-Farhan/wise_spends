import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_spending_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Savings Plan Spending Repository Interface
abstract class ISavingsPlanSpendingRepository
    extends
        ICrudRepository<
          SavingsPlanSpendingTable,
          $SavingsPlanSpendingTableTable,
          SavingsPlanSpendingTableCompanion,
          SvngPlnSpending
        > {
  ISavingsPlanSpendingRepository(AppDatabase db)
      : super(db, db.savingsPlanSpendingTable);

  /// Watch all spending for a plan
  Stream<List<SvngPlnSpending>> watchByPlanId(String planId);

  /// Get all spending for a plan
  Future<List<SvngPlnSpending>> getByPlanId(String planId);

  /// Delete all spending for a plan
  Future<void> deleteByPlanId(String planId);
}
