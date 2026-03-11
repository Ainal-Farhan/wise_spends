import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart' show Value;
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_item_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_item_tag_repository.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_item_entity.dart';
import 'budget_plan_items_list_event.dart';
import 'budget_plan_items_list_state.dart';
import 'package:collection/collection.dart';

/// Budget Plan Items List BLoC — manages the list of budget plan items.
class BudgetPlanItemsListBloc
    extends Bloc<BudgetPlanItemsListEvent, BudgetPlanItemsListState> {
  final ISavingsPlanItemRepository _itemRepository;
  final ISavingsPlanItemTagRepository _tagRepository;

  BudgetPlanItemsListBloc(this._itemRepository, this._tagRepository)
    : super(BudgetPlanItemsListInitial()) {
    on<LoadBudgetPlanItems>(_onLoadBudgetPlanItems);
    on<RefreshBudgetPlanItems>(_onRefreshBudgetPlanItems);
    on<FilterBudgetPlanItems>(_onFilterBudgetPlanItems);
    on<CreateBudgetPlanItem>(_onCreateBudgetPlanItem);
    on<UpdateBudgetPlanItem>(_onUpdateBudgetPlanItem);
    on<DeleteBudgetPlanItem>(_onDeleteBudgetPlanItem);
    on<ReorderBudgetPlanItems>(_onReorderBudgetPlanItems);
    on<ClearBudgetPlanItems>(_onClearBudgetPlanItems);
  }

  // ---------------------------------------------------------------------------
  // Load — full load with Loading state
  // ---------------------------------------------------------------------------

  Future<void> _onLoadBudgetPlanItems(
    LoadBudgetPlanItems event,
    Emitter<BudgetPlanItemsListState> emit,
  ) async {
    emit(BudgetPlanItemsListLoading());
    try {
      final itemsWithTags = await _fetchItemsWithTags(event.planId);
      _emitLoaded(emit, itemsWithTags);
    } catch (e) {
      emit(BudgetPlanItemsListError('Failed to load items: ${e.toString()}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh — no Loading flicker, preserves current filters
  // ---------------------------------------------------------------------------

  Future<void> _onRefreshBudgetPlanItems(
    RefreshBudgetPlanItems event,
    Emitter<BudgetPlanItemsListState> emit,
  ) async {
    final currentLoaded = state is BudgetPlanItemsListLoaded
        ? state as BudgetPlanItemsListLoaded
        : null;

    try {
      final itemsWithTags = await _fetchItemsWithTags(event.planId);
      _emitLoaded(
        emit,
        itemsWithTags,
        filterPaymentStatus: currentLoaded?.filterPaymentStatus,
        filterTag: currentLoaded?.filterTag,
      );
    } catch (e) {
      if (currentLoaded != null) {
        emit(
          BudgetPlanItemsListRefreshError(
            message: 'Failed to refresh: ${e.toString()}',
            previousState: currentLoaded,
          ),
        );
        emit(currentLoaded);
      } else {
        emit(
          BudgetPlanItemsListError('Failed to refresh items: ${e.toString()}'),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Filter — client-side only, no DB call
  // ---------------------------------------------------------------------------

  void _onFilterBudgetPlanItems(
    FilterBudgetPlanItems event,
    Emitter<BudgetPlanItemsListState> emit,
  ) {
    if (state is! BudgetPlanItemsListLoaded) return;
    final current = state as BudgetPlanItemsListLoaded;

    emit(
      current.copyWith(
        filteredItems: _applyFilters(
          current.items,
          event.paymentStatus,
          event.tag,
        ),
        filterPaymentStatus: event.paymentStatus,
        filterTag: event.tag,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Create — delegates fully to repository
  // ---------------------------------------------------------------------------

  Future<void> _onCreateBudgetPlanItem(
    CreateBudgetPlanItem event,
    Emitter<BudgetPlanItemsListState> emit,
  ) async {
    final currentFilter = state is BudgetPlanItemsListLoaded
        ? (state as BudgetPlanItemsListLoaded).filterPaymentStatus
        : null;
    final currentTag = state is BudgetPlanItemsListLoaded
        ? (state as BudgetPlanItemsListLoaded).filterTag
        : null;

    try {
      final sortOrder = await _itemRepository.getNextSortOrder(event.planId);

      // Auto-set isCompleted if fully paid
      final isFullyPaid =
          event.amountPaid + event.depositPaid >= event.totalCost;

      // insertOne is the correct ICrudRepository method name
      final inserted = await _itemRepository.insertOne(
        SavingsPlanItemTableCompanion.insert(
          createdBy: 'system',
          planId: event.planId,
          bil: Value(event.bil),
          sortOrder: Value(sortOrder),
          name: event.name,
          totalCost: Value(event.totalCost),
          depositPaid: Value(event.depositPaid),
          amountPaid: Value(event.amountPaid),
          notes: Value(event.notes),
          dueDate: Value(event.dueDate),
          isCompleted: Value(isFullyPaid),
          dateUpdated: DateTime.now(),
          lastModifiedBy: 'system',
        ),
      );

      if (event.tags.isNotEmpty) {
        await _tagRepository.addTags(inserted.id, event.tags);
      }

      final itemsWithTags = await _fetchItemsWithTags(event.planId);

      // Emit loaded state — list reflects the new item
      _emitLoaded(
        emit,
        itemsWithTags,
        filterPaymentStatus: currentFilter,
        filterTag: currentTag,
      );

      // Emit transient notification for BlocListener (snackbar)
      // Don't await this - it's just a notification
      final created = itemsWithTags.firstWhereOrNull(
        (i) => i.id == inserted.id,
      );
      if (created != null && !emit.isDone) {
        emit(BudgetPlanItemCreated(created));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(
          BudgetPlanItemsListError('Failed to create item: ${e.toString()}'),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Update — delegates fully to repository, handles clearNotes/clearDueDate
  // ---------------------------------------------------------------------------

  Future<void> _onUpdateBudgetPlanItem(
    UpdateBudgetPlanItem event,
    Emitter<BudgetPlanItemsListState> emit,
  ) async {
    if (state is! BudgetPlanItemsListLoaded) return;
    final current = state as BudgetPlanItemsListLoaded;

    try {
      // Auto-calculate isCompleted based on payment amounts
      // Only auto-calculate if user didn't explicitly set isCompleted
      final bool isCompleted;
      if (event.isCompleted != null) {
        // User explicitly set isCompleted, use their value
        isCompleted = event.isCompleted!;
      } else {
        // Auto-calculate: mark as completed if fully paid
        final totalCost =
            event.totalCost ??
            current.items.firstWhere((i) => i.id == event.itemId).totalCost;
        final amountPaid =
            event.amountPaid ??
            current.items.firstWhere((i) => i.id == event.itemId).amountPaid;
        isCompleted = amountPaid + (event.depositPaid ?? .0) >= totalCost;
      }

      // updatePart is the correct ICrudRepository method name
      await _itemRepository.updatePart(
        tableCompanion: SavingsPlanItemTableCompanion(
          bil: Value(event.bil),
          name: Value(event.name ?? ''),
          totalCost: Value(event.totalCost ?? .0),
          depositPaid: Value(event.depositPaid ?? .0),
          amountPaid: Value(event.amountPaid ?? .0),
          // clearNotes sentinel: explicit null vs no-change
          notes: event.clearNotes ? const Value(null) : Value(event.notes),
          isCompleted: Value(isCompleted),
          dueDate: event.clearDueDate
              ? const Value(null)
              : Value(event.dueDate),
        ),
        id: event.itemId,
      );

      if (event.tags != null) {
        await _tagRepository.replaceTags(event.itemId, event.tags!);
      }

      final planId = current.items.first.planId;
      final itemsWithTags = await _fetchItemsWithTags(planId);

      _emitLoaded(
        emit,
        itemsWithTags,
        filterPaymentStatus: current.filterPaymentStatus,
        filterTag: current.filterTag,
      );

      // Emit transient notification for BlocListener (snackbar)
      final updated = itemsWithTags.firstWhereOrNull(
        (i) => i.id == event.itemId,
      );
      if (updated != null && !emit.isDone) {
        emit(BudgetPlanItemUpdated(updated));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(
          BudgetPlanItemsListError('Failed to update item: ${e.toString()}'),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Delete — preserves list on error
  // ---------------------------------------------------------------------------

  Future<void> _onDeleteBudgetPlanItem(
    DeleteBudgetPlanItem event,
    Emitter<BudgetPlanItemsListState> emit,
  ) async {
    final snapshot = state is BudgetPlanItemsListLoaded
        ? state as BudgetPlanItemsListLoaded
        : null;

    try {
      await _tagRepository.deleteByItemId(event.itemId);
      await _itemRepository.deleteById(id: event.itemId);

      final itemsWithTags = await _fetchItemsWithTags(event.planId);
      _emitLoaded(emit, itemsWithTags);

      // Emit transient notification for BlocListener (snackbar)
      if (!emit.isDone) {
        emit(BudgetPlanItemDeleted(event.itemId));
      }
    } catch (e) {
      if (!emit.isDone && snapshot != null) {
        emit(
          BudgetPlanItemsListDeleteError(
            message: 'Failed to delete item: ${e.toString()}',
            previousState: snapshot,
          ),
        );
        emit(snapshot);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Reorder — fractional indexing via repository
  // ---------------------------------------------------------------------------

  Future<void> _onReorderBudgetPlanItems(
    ReorderBudgetPlanItems event,
    Emitter<BudgetPlanItemsListState> emit,
  ) async {
    if (state is! BudgetPlanItemsListLoaded) return;
    final current = state as BudgetPlanItemsListLoaded;

    try {
      await _itemRepository.updateSortOrder(event.itemId, event.newSortOrder);

      final planId = current.items.first.planId;
      final itemsWithTags = await _fetchItemsWithTags(planId);

      _emitLoaded(
        emit,
        itemsWithTags,
        filterPaymentStatus: current.filterPaymentStatus,
        filterTag: current.filterTag,
      );
    } catch (e) {
      emit(
        BudgetPlanItemsListError('Failed to reorder items: ${e.toString()}'),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Clear — reset state when navigating away from a plan
  // ---------------------------------------------------------------------------

  void _onClearBudgetPlanItems(
    ClearBudgetPlanItems event,
    Emitter<BudgetPlanItemsListState> emit,
  ) {
    emit(BudgetPlanItemsListInitial());
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Fetch all items for a plan and attach their tags in one pass
  Future<List<BudgetPlanItemEntity>> _fetchItemsWithTags(String planId) async {
    final items = await _itemRepository.getByPlanId(planId);
    if (items.isEmpty) return [];

    final tagsByItem = await _tagRepository.getByItemIds(
      items.map((i) => i.id).toList(),
    );

    return items.map((item) {
      final tags = tagsByItem[item.id]?.map((t) => t.tagName).toList() ?? [];
      return BudgetPlanItemEntity(
        id: item.id,
        planId: item.planId,
        sortOrder: item.sortOrder,
        bil: item.bil ?? '',
        name: item.name,
        totalCost: item.totalCost,
        depositPaid: item.depositPaid,
        amountPaid: item.amountPaid,
        notes: item.notes,
        isCompleted: item.isCompleted,
        dueDate: item.dueDate,
        createdAt: item.dateCreated,
        updatedAt: item.dateUpdated,
        tags: tags,
      );
    }).toList();
  }

  /// Emit the correct loaded/empty state, applying current filters
  void _emitLoaded(
    Emitter<BudgetPlanItemsListState> emit,
    List<BudgetPlanItemEntity> items, {
    String? filterPaymentStatus,
    String? filterTag,
  }) {
    if (items.isEmpty) {
      emit(const BudgetPlanItemsListEmpty());
      return;
    }

    final summary = BudgetPlanItemsSummary.fromItems(items);
    final filtered = _applyFilters(items, filterPaymentStatus, filterTag);

    emit(
      BudgetPlanItemsListLoaded(
        items: items,
        filteredItems: filtered,
        filterPaymentStatus: filterPaymentStatus,
        filterTag: filterTag,
        summary: summary,
      ),
    );
  }

  /// Client-side filter — no DB call
  List<BudgetPlanItemEntity> _applyFilters(
    List<BudgetPlanItemEntity> items,
    String? paymentStatus,
    String? tag,
  ) {
    var filtered = items;

    if (paymentStatus != null) {
      filtered = filtered.where((item) {
        switch (paymentStatus) {
          case 'paid':
            return item.isFullyPaid;
          case 'deposit':
            return item.depositPaid > 0 && !item.isFullyPaid;
          case 'outstanding':
            return !item.isFullyPaid && item.depositPaid == 0;
          default:
            return true;
        }
      }).toList();
    }

    if (tag != null) {
      filtered = filtered.where((item) => item.tags.contains(tag)).toList();
    }

    return filtered;
  }
}
