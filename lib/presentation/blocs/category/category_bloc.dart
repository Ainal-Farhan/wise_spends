import 'package:bloc/bloc.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

/// Category BLoC - manages category state and business logic
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ICategoryRepository _repository;

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<LoadIncomeCategoriesEvent>(_onLoadIncomeCategories);
    on<LoadExpenseCategoriesEvent>(_onLoadExpenseCategories);
    on<LoadCategoriesForTransactionTypeEvent>(_onLoadCategoriesForTransactionType);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  /// Load all categories
  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Load income categories
  Future<void> _onLoadIncomeCategories(
    LoadIncomeCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getIncomeCategories();
      emit(IncomeCategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Load expense categories
  Future<void> _onLoadExpenseCategories(
    LoadExpenseCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getExpenseCategories();
      emit(ExpenseCategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Load categories for transaction type
  Future<void> _onLoadCategoriesForTransactionType(
    LoadCategoriesForTransactionTypeEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getCategoriesForTransactionType(
        event.type,
      );
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Create a new category
  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final category = CategoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        iconCodePoint: event.iconCodePoint,
        iconFontFamily: event.iconFontFamily,
        isIncome: event.isIncome,
        isExpense: event.isExpense,
        orderIndex: event.orderIndex,
        createdAt: DateTime.now(),
      );

      final created = await _repository.createCategory(category);
      emit(CategoryCreated(created));

      // Reload categories after creation
      add(LoadCategoriesEvent());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Update an existing category
  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final updated = await _repository.updateCategory(event.category);
      emit(CategoryUpdated(updated));

      // Reload categories after update
      add(LoadCategoriesEvent());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Delete a category
  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.deleteCategory(event.categoryId);
      emit(CategoryDeleted(event.categoryId));

      // Reload categories after deletion
      add(LoadCategoriesEvent());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
