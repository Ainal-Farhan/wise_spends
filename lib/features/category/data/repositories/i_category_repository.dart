import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/category_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

/// Category repository interface - defines contract for data layer
abstract class ICategoryRepository
    extends
        ICrudRepository<
          CategoryTable,
          $CategoryTableTable,
          CategoryTableCompanion,
          TrnsctnCategory
        > {
  ICategoryRepository(AppDatabase db) : super(db, db.categoryTable);

  /// Get all categories
  Future<List<CategoryEntity>> getAllCategories();

  /// Get income categories
  Future<List<CategoryEntity>> getIncomeCategories();

  /// Get expense categories
  Future<List<CategoryEntity>> getExpenseCategories();

  /// Get a single category by ID
  Future<CategoryEntity?> getCategoryById(String id);

  /// Get category by name
  Future<CategoryEntity?> getCategoryByName(String name);

  /// Create a new category
  Future<CategoryEntity> createCategory(CategoryEntity category);

  /// Update an existing category
  Future<CategoryEntity> updateCategory(CategoryEntity category);

  /// Delete a category
  Future<void> deleteCategory(String id);

  /// Get categories for transaction type
  Future<List<CategoryEntity>> getCategoriesForTransactionType(
    TransactionType type,
  );
}
