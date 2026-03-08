import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_item_tag_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Savings Plan Item Tag Repository Interface
abstract class ISavingsPlanItemTagRepository
    extends
        ICrudRepository<
          SavingsPlanItemTagTable,
          $SavingsPlanItemTagTableTable,
          SavingsPlanItemTagTableCompanion,
          SvngPlnItemTag
        > {
  ISavingsPlanItemTagRepository(AppDatabase db) : super(db, db.savingsPlanItemTagTable);

  /// Watch all tags for an item
  Stream<List<SvngPlnItemTag>> watchByItemId(String itemId);

  /// Get all tags for an item
  Future<List<SvngPlnItemTag>> getByItemId(String itemId);

  /// Get all tags for multiple items
  Future<Map<String, List<SvngPlnItemTag>>> getByItemIds(List<String> itemIds);

  /// Delete all tags for an item
  Future<void> deleteByItemId(String itemId);

  /// Add multiple tags to an item
  Future<void> addTags(String itemId, List<String> tagNames);

  /// Replace all tags for an item (delete old, add new)
  Future<void> replaceTags(String itemId, List<String> tagNames);

  /// Get all unique tags across all items
  Future<List<String>> getAllUniqueTags();

  /// Get items by tag
  Future<List<SvngPlnItem>> getItemsByTag(String planId, String tagName);
}
