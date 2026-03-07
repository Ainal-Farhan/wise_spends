import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_deposit_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Savings Plan Deposit Repository Interface
abstract class ISavingsPlanDepositRepository
    extends
        ICrudRepository<
          SavingsPlanDepositTable,
          $SavingsPlanDepositTableTable,
          SavingsPlanDepositTableCompanion,
          SvngPlnDeposit
        > {
  ISavingsPlanDepositRepository(AppDatabase db)
      : super(db, db.savingsPlanDepositTable);

  /// Watch all deposits for a plan
  Stream<List<SvngPlnDeposit>> watchByPlanId(String planId);

  /// Get all deposits for a plan
  Future<List<SvngPlnDeposit>> getByPlanId(String planId);

  /// Delete all deposits for a plan
  Future<void> deleteByPlanId(String planId);
}
