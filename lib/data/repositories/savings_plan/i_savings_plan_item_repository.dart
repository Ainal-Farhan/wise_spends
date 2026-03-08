import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_item_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Savings Plan Item Repository Interface
abstract class ISavingsPlanItemRepository
    extends
        ICrudRepository<
          SavingsPlanItemTable,
          $SavingsPlanItemTableTable,
          SavingsPlanItemTableCompanion,
          SvngPlnItem
        > {
  ISavingsPlanItemRepository(AppDatabase db) : super(db, db.savingsPlanItemTable);

  /// Watch all items for a plan (ordered by sortOrder)
  Stream<List<SvngPlnItem>> watchByPlanId(String planId);

  /// Get all items for a plan (ordered by sortOrder)
  Future<List<SvngPlnItem>> getByPlanId(String planId);

  /// Delete all items for a plan
  Future<void> deleteByPlanId(String planId);

  /// Get item by ID
  Future<SvngPlnItem?> getById(String itemId);

  /// Update sort order for an item (for fractional indexing)
  Future<void> updateSortOrder(String itemId, double newSortOrder);

  /// Get next sort order for inserting a new item at the end
  Future<double> getNextSortOrder(String planId);

  /// Calculate sort order for inserting between two items
  static double calculateSortOrderBetween(double? before, double? after) {
    if (before == null && after == null) return 1000.0;
    if (before == null) return after! - 1000.0;
    if (after == null) return before + 1000.0;
    return (before + after) / 2;
  }
}
