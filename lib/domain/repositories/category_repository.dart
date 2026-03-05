import 'package:wise_spends/core/di/i_singleton.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Category repository interface - defines contract for data layer
abstract class ICategoryRepository implements ISingleton {
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
