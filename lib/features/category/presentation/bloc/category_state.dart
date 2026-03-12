import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';

/// Category BLoC states
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CategoryInitial extends CategoryState {}

/// Loading state
class CategoryLoading extends CategoryState {}

/// Categories loaded successfully
class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  final String? filterType;

  const CategoryLoaded(this.categories, {this.filterType});

  @override
  List<Object?> get props => [categories, filterType];
}

/// Income categories loaded
class IncomeCategoriesLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const IncomeCategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

/// Expense categories loaded
class ExpenseCategoriesLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const ExpenseCategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

/// Category created successfully
class CategoryCreated extends CategoryState {
  final CategoryEntity category;

  const CategoryCreated(this.category);

  @override
  List<Object> get props => [category];
}

/// Category updated successfully
class CategoryUpdated extends CategoryState {
  final CategoryEntity category;

  const CategoryUpdated(this.category);

  @override
  List<Object> get props => [category];
}

/// Category deleted successfully
class CategoryDeleted extends CategoryState {
  final String categoryId;

  const CategoryDeleted(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

/// Error state
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
