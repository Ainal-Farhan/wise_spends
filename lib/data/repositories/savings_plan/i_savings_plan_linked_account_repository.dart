import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_linked_account_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Savings Plan Linked Account Repository Interface
abstract class ISavingsPlanLinkedAccountRepository
    extends
        ICrudRepository<
          SavingsPlanLinkedAccountTable,
          $SavingsPlanLinkedAccountTableTable,
          SavingsPlanLinkedAccountTableCompanion,
          SvngPlnLinkedAccount
        > {
  ISavingsPlanLinkedAccountRepository(AppDatabase db)
      : super(db, db.savingsPlanLinkedAccountTable);

  /// Watch all linked accounts for a plan
  Stream<List<SvngPlnLinkedAccount>> watchByPlanId(String planId);

  /// Get all linked accounts for a plan
  Future<List<SvngPlnLinkedAccount>> getByPlanId(String planId);

  /// Delete all linked accounts for a plan
  Future<void> deleteByPlanId(String planId);
}
