import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_item_tag_repository.dart';

/// Savings Plan Item Tag Repository Implementation
class SavingsPlanItemTagRepository extends ISavingsPlanItemTagRepository {
  SavingsPlanItemTagRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'SavingsPlanItemTagTable';

  @override
  Stream<List<SvngPlnItemTag>> watchByItemId(String itemId) {
    return (db.select(
      db.savingsPlanItemTagTable,
    )..where((tbl) => tbl.itemId.equals(itemId))).watch();
  }

  @override
  Future<List<SvngPlnItemTag>> getByItemId(String itemId) async {
    return (db.select(
      db.savingsPlanItemTagTable,
    )..where((tbl) => tbl.itemId.equals(itemId))).get();
  }

  @override
  Future<Map<String, List<SvngPlnItemTag>>> getByItemIds(
    List<String> itemIds,
  ) async {
    if (itemIds.isEmpty) return {};

    final tags = await (db.select(
      db.savingsPlanItemTagTable,
    )..where((tbl) => tbl.itemId.isIn(itemIds))).get();

    // Group by item ID
    final Map<String, List<SvngPlnItemTag>> grouped = {};
    for (final tag in tags) {
      grouped.putIfAbsent(tag.itemId, () => []).add(tag);
    }
    return grouped;
  }

  @override
  Future<void> deleteByItemId(String itemId) async {
    await (db.delete(
      db.savingsPlanItemTagTable,
    )..where((tbl) => tbl.itemId.equals(itemId))).go();
  }

  @override
  Future<void> addTags(String itemId, List<String> tagNames) async {
    if (tagNames.isEmpty) return;

    final companions = tagNames.map((tagName) {
      return SavingsPlanItemTagTableCompanion.insert(
        itemId: itemId,
        tagName: tagName,
        createdBy: 'system',
        lastModifiedBy: 'system',
        dateUpdated: DateTime.now(),
      );
    }).toList();

    await db.batch((batch) {
      for (final companion in companions) {
        batch.insert(
          db.savingsPlanItemTagTable,
          companion,
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  @override
  Future<void> replaceTags(String itemId, List<String> tagNames) async {
    await db.transaction(() async {
      // Delete existing tags
      await deleteByItemId(itemId);
      // Add new tags
      await addTags(itemId, tagNames);
    });
  }

  @override
  Future<List<String>> getAllUniqueTags() async {
    final query = db.select(db.savingsPlanItemTagTable);
    final tags = await query.get();
    return tags.map((t) => t.tagName).toSet().toList()..sort();
  }

  @override
  Future<List<SvngPlnItem>> getItemsByTag(String planId, String tagName) async {
    final query =
        db.select(db.savingsPlanItemTable).join([
            leftOuterJoin(
              db.savingsPlanItemTagTable,
              db.savingsPlanItemTable.id.equalsExp(
                db.savingsPlanItemTagTable.itemId,
              ),
            ),
          ])
          ..where(db.savingsPlanItemTable.planId.equals(planId))
          ..where(db.savingsPlanItemTagTable.tagName.equals(tagName));

    final results = await query.get();
    return results.map((row) {
      return row.readTable(db.savingsPlanItemTable);
    }).toList();
  }

  @override
  SvngPlnItemTag fromJson(Map<String, dynamic> json) =>
      SvngPlnItemTag.fromJson(json);
}
