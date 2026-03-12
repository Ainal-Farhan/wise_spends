import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

/// Category BLoC events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load all categories
class LoadCategoriesEvent extends CategoryEvent {}

/// Load income categories
class LoadIncomeCategoriesEvent extends CategoryEvent {}

/// Load expense categories
class LoadExpenseCategoriesEvent extends CategoryEvent {}

/// Load categories for transaction type
class LoadCategoriesForTransactionTypeEvent extends CategoryEvent {
  final TransactionType type;

  const LoadCategoriesForTransactionTypeEvent(this.type);

  @override
  List<Object> get props => [type];
}

/// Create a new category
class CreateCategoryEvent extends CategoryEvent {
  final String name;
  final String iconCodePoint;
  final String iconFontFamily;
  final bool isIncome;
  final bool isExpense;
  final int orderIndex;

  const CreateCategoryEvent({
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.isIncome = false,
    this.isExpense = false,
    this.orderIndex = 0,
  });

  @override
  List<Object> get props => [
        name,
        iconCodePoint,
        iconFontFamily,
        isIncome,
        isExpense,
        orderIndex,
      ];
}

/// Update a category
class UpdateCategoryEvent extends CategoryEvent {
  final CategoryEntity category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

/// Delete a category
class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;

  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

/// Change category filter type
class ChangeCategoryFilterEvent extends CategoryEvent {
  final String filterType;

  const ChangeCategoryFilterEvent(this.filterType);

  @override
  List<Object> get props => [filterType];
}
