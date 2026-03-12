import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/category/data/repositories/i_category_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

class CategoryRepository extends ICategoryRepository {
  static const _uuid = Uuid();

  final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
      .getStartupManager();

  CategoryRepository() : super(AppDatabase());

  @override
  void dispose() {}

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final rows = await db.select(db.categoryTable).get();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories() async {
    final all = await getAllCategories();
    return all.where((c) => c.isIncome).toList();
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories() async {
    final all = await getAllCategories();
    return all.where((c) => c.isExpense).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    final query = db.select(db.categoryTable)
      ..where((tbl) => tbl.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _mapToEntity(rows.first);
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    final query = db.select(db.categoryTable)
      ..where((tbl) => tbl.name.equals(name));
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _mapToEntity(rows.first);
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    final id = category.id.isEmpty ? _uuid.v4() : category.id;

    final companion = CategoryTableCompanion.insert(
      id: Value(id),
      name: category.name,
      iconCodePoint: category.iconCodePoint,
      iconFontFamily: Value(category.iconFontFamily),
      isIncome: Value(category.isIncome),
      isExpense: Value(category.isExpense),
      orderIndex: Value(category.orderIndex),
      isActive: Value(category.isActive),
      createdAt: Value(category.createdAt ?? DateTime.now()),
      createdBy: startupManager.currentUser.name,
      dateUpdated: DateTime.now(),
      lastModifiedBy: startupManager.currentUser.name,
    );

    await db.into(db.categoryTable).insert(companion);

    // Return the entity with the assigned ID so the BLoC can cache it correctly
    return category.copyWith(id: id);
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final query = db.update(db.categoryTable)
      ..where((tbl) => tbl.id.equals(category.id));

    await query.write(
      CategoryTableCompanion(
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
    final query = db.delete(db.categoryTable)
      ..where((tbl) => tbl.id.equals(id));
    await query.go();
  }

  CategoryEntity _mapToEntity(TrnsctnCategory row) {
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

  @override
  Future<List<CategoryEntity>> getCategoriesForTransactionType(
    TransactionType type,
  ) async {
    final all = await getAllCategories();
    switch (type) {
      case TransactionType.income:
        return all
            .where((c) => c.isIncome || (!c.isIncome && !c.isExpense))
            .toList();
      case TransactionType.expense:
        return all
            .where((c) => c.isExpense || (!c.isIncome && !c.isExpense))
            .toList();
      case TransactionType.transfer:
      case TransactionType.commitment:
      case TransactionType.budgetPlanDeposit:
      case TransactionType.budgetPlanExpense:
        return [];
    }
  }

  @override
  String getTypeName() => 'CategoryTable';

  @override
  TrnsctnCategory fromJson(Map<String, dynamic> json) =>
      TrnsctnCategory.fromJson(json);
}
