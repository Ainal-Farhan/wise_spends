import 'package:bloc/bloc.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/data/repositories/category/i_category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ICategoryRepository _repository;
  List<CategoryEntity> _allCategories = [];

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<LoadIncomeCategoriesEvent>(_onLoadIncomeCategories);
    on<LoadExpenseCategoriesEvent>(_onLoadExpenseCategories);
    on<LoadCategoriesForTransactionTypeEvent>(
      _onLoadCategoriesForTransactionType,
    );
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<ChangeCategoryFilterEvent>(_onChangeCategoryFilter);
  }

  String get _currentFilterType {
    final s = state;
    return s is CategoryLoaded ? (s.filterType ?? 'all') : 'all';
  }

  void _emitLoaded(Emitter<CategoryState> emit, {String? filterType}) {
    emit(
      CategoryLoaded(
        List<CategoryEntity>.from(_allCategories),
        filterType: filterType ?? _currentFilterType,
      ),
    );
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      _allCategories = await _repository.getAllCategories();
      _emitLoaded(emit);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

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

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final category = CategoryEntity(
        id: '',
        name: event.name,
        iconCodePoint: event.iconCodePoint,
        iconFontFamily: event.iconFontFamily,
        isIncome: event.isIncome,
        isExpense: event.isExpense,
        orderIndex: event.orderIndex,
        createdAt: DateTime.now(),
      );

      final created = await _repository.createCategory(category);
      _allCategories = [..._allCategories, created];

      emit(CategoryCreated(created));
      _emitLoaded(emit);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final updated = await _repository.updateCategory(event.category);

      _allCategories = _allCategories
          .map((c) => c.id == updated.id ? updated : c)
          .toList();

      emit(CategoryUpdated(updated));
      _emitLoaded(emit);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await _repository.deleteCategory(event.categoryId);

      _allCategories = _allCategories
          .where((c) => c.id != event.categoryId)
          .toList();

      emit(CategoryDeleted(event.categoryId));
      _emitLoaded(emit);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onChangeCategoryFilter(
    ChangeCategoryFilterEvent event,
    Emitter<CategoryState> emit,
  ) {
    _emitLoaded(emit, filterType: event.filterType);
  }
}
