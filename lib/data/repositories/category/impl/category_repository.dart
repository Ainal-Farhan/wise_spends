import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/repositories/category_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Category Repository Implementation
/// Handles all database operations for categories
class CategoryRepository extends ICategoryRepository {
  final AppDatabase _db = AppDatabase();

  @override
  void dispose() {
    // No resources to dispose
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final query = _db.select(_db.categories);
    final rows = await query.get();

    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories() async {
    final allCategories = await getAllCategories();
    return allCategories.where((c) => c.isIncome).toList();
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories() async {
    final allCategories = await getAllCategories();
    return allCategories.where((c) => c.isExpense).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    final query = _db.select(_db.categories)..where((tbl) => tbl.id.equals(id));
    final rows = await query.get();

    if (rows.isEmpty) return null;
    return _mapToEntity(rows.first);
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    final query = _db.select(_db.categories)
      ..where((tbl) => tbl.name.equals(name));
    final rows = await query.get();

    if (rows.isEmpty) return null;
    return _mapToEntity(rows.first);
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    final companion = CategoriesCompanion.insert(
      id: category.id,
      name: category.name,
      iconCodePoint: category.iconCodePoint,
      iconFontFamily: Value(category.iconFontFamily),
      isIncome: Value(category.isIncome),
      isExpense: Value(category.isExpense),
      orderIndex: Value(category.orderIndex),
      isActive: Value(category.isActive),
      createdAt: Value(category.createdAt ?? DateTime.now()),
    );

    await _db.into(_db.categories).insert(companion);
    return category;
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final query = _db.update(_db.categories)
      ..where((tbl) => tbl.id.equals(category.id));

    await query.write(
      CategoriesCompanion(
        name: Value(category.name),
        iconCodePoint: Value(category.iconCodePoint),
        iconFontFamily: Value(category.iconFontFamily),
        isIncome: Value(category.isIncome),
        isExpense: Value(category.isExpense),
        orderIndex: Value(category.orderIndex),
        isActive: Value(category.isActive),
      ),
    );

    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final query = _db.delete(_db.categories)..where((tbl) => tbl.id.equals(id));
    await query.go();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesForTransactionType(
    TransactionType type,
  ) async {
    final allCategories = await getAllCategories();

    switch (type) {
      case TransactionType.income:
        return allCategories
            .where((c) => c.isIncome || (!c.isIncome && !c.isExpense))
            .toList();
      case TransactionType.expense:
        return allCategories
            .where((c) => c.isExpense || (!c.isIncome && !c.isExpense))
            .toList();
      case TransactionType.transfer:
        return []; // Transfers don't need categories
    }
  }

  /// Map database row to entity
  CategoryEntity _mapToEntity(Category row) {
    return CategoryEntity(
      id: row.id,
      name: row.name,
      iconCodePoint: row.iconCodePoint,
      iconFontFamily: row.iconFontFamily,
      isIncome: row.isIncome,
      isExpense: row.isExpense,
      orderIndex: row.orderIndex,
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }
}
