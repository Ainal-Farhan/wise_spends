import 'package:bloc/bloc.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/commitment/data/repositories/i_commitment_task_repository.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/commitment/domain/entities/task_group_vo.dart';
import 'package:wise_spends/features/commitment/domain/utils/task_grouper.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'commitment_task_event.dart';
import 'commitment_task_state.dart';

class CommitmentTaskBloc
    extends Bloc<CommitmentTaskEvent, CommitmentTaskState> {
  final ICommitmentTaskRepository _repository;

  Function? updateAppBar;

  CommitmentTaskBloc(this._repository) : super(CommitmentTaskInitial()) {
    on<LoadCommitmentTasksEvent>(_onLoadCommitmentTasks);
    on<UpdateStatusCommitmentTaskEvent>(_onUpdateStatusCommitmentTask);
    on<UpdateStatusCommitmentTaskListEvent>(
      _onUpdateStatusCommitmentTaskListEvent,
    );
    on<FilterCommitmentTasksEvent>(_onFilterCommitmentTasks);
    on<AddCommitmentTaskEvent>(_onAddCommitmentTask);
    on<EditCommitmentTaskEvent>(_onEditCommitmentTask);
    on<DeleteCommitmentTaskEvent>(_onDeleteCommitmentTask);
    on<LoadMoreCommitmentTasksEvent>(_onLoadMoreCommitmentTasks);
  }

  Future<void> _onLoadCommitmentTasks(
    LoadCommitmentTasksEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    String filterStatus = 'pending';
    if (state is CommitmentTaskLoaded) {
      filterStatus = (state as CommitmentTaskLoaded).filterStatus;
    }

    emit(CommitmentTaskLoading());
    try {
      final isIncomplete = filterStatus == 'pending';

      // For pending: load all tasks (users need to see everything to complete)
      // For completed: use lazy loading (only first page)
      final List<CommitmentTaskVO> tasks;
      final bool hasMore;
      final int pendingCount;

      if (isIncomplete) {
        // Load ALL pending tasks
        tasks = await _repository.getCommitmentTasks(false);
        hasMore = false; // No lazy loading for pending
        pendingCount = tasks.length;
      } else {
        // Load first page of completed tasks
        tasks = await _repository.getCommitmentTasks(
          true,
          limit: 20,
          offset: 0,
        );
        hasMore = tasks.length == 20;
        // Keep existing pending count from state
        final currentState = state;
        pendingCount = (currentState is CommitmentTaskLoaded) 
            ? currentState.pendingCount 
            : 0;
      }

      // Fetch savings for dropdown pickers
      final savingManager = SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager();
      final List<ListSavingVO> savingVOList = await savingManager
          .loadListSavingVOList();

      // Fetch payees for dropdown pickers
      final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getPayeeRepository();
      final List<ExpnsPayee> payees = await payeeRepo.watchAll().first;
      final List<PayeeVO> payeeVOList = payees
          .map((p) => PayeeVO.fromExpnsPayee(p))
          .toList();

      // Group tasks and calculate ungrouped
      List<TaskGroupVO> groupedTasks = [];
      List<CommitmentTaskVO> ungroupedTasks = [];

      if (isIncomplete) {
        // Only group pending tasks
        groupedTasks = TaskGrouper.groupTasks(tasks, savingVOList);
        ungroupedTasks = TaskGrouper.getUngroupedTasks(tasks, savingVOList);
      }

      emit(
        CommitmentTaskLoaded(
          tasks,
          savingVOList,
          payeeVOList,
          filterStatus: filterStatus,
          groupedTasks: groupedTasks,
          ungroupedTasks: ungroupedTasks,
          currentPage: 1,
          hasMore: hasMore,
          pendingCount: pendingCount,
        ),
      );
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }

  Future<void> _onUpdateStatusCommitmentTaskListEvent(
    UpdateStatusCommitmentTaskListEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    emit(CommitmentTaskLoading());
    try {
      await _updateStatusCommitmentTaskList(event.taskVOList, event.isDone);

      if (updateAppBar != null) {
        updateAppBar!();
      }

      emit(CommitmentTaskUpdated('Successfully updated task status'));
      // Reload the tasks after update
      add(LoadCommitmentTasksEvent());
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }

  Future<void> _updateStatusCommitmentTaskList(
    List<CommitmentTaskVO> taskVOList,
    bool isDone,
  ) async {
    for (var taskVO in taskVOList) {
      await _repository.updateTaskStatus(isDone, taskVO);
    }
  }

  Future<void> _onUpdateStatusCommitmentTask(
    UpdateStatusCommitmentTaskEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    emit(CommitmentTaskLoading());
    try {
      await _updateStatusCommitmentTaskList([event.taskVO], event.isDone);

      if (updateAppBar != null) {
        updateAppBar!();
      }

      emit(CommitmentTaskUpdated('Successfully updated task status'));
      // Reload the tasks after update
      add(LoadCommitmentTasksEvent());
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }

  Future<void> _onFilterCommitmentTasks(
    FilterCommitmentTasksEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    // First update the filter status, then reload with new filter
    if (state is CommitmentTaskLoaded) {
      final currentState = state as CommitmentTaskLoaded;
      // Update filter status immediately
      emit(currentState.copyWith(filterStatus: event.filterStatus));
      // Now reload tasks for the new filter
      add(LoadCommitmentTasksEvent());
    }
  }

  Future<void> _onAddCommitmentTask(
    AddCommitmentTaskEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    emit(CommitmentTaskLoading());
    try {
      await _repository.addCommitmentTask(event.taskVO);

      if (updateAppBar != null) {
        updateAppBar!();
      }

      emit(CommitmentTaskUpdated('Successfully added task'));
      add(LoadCommitmentTasksEvent());
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }

  Future<void> _onEditCommitmentTask(
    EditCommitmentTaskEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    emit(CommitmentTaskLoading());
    try {
      await _repository.editCommitmentTask(event.taskVO);

      if (updateAppBar != null) {
        updateAppBar!();
      }

      emit(CommitmentTaskUpdated('Successfully edited task'));
      add(LoadCommitmentTasksEvent());
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }

  Future<void> _onDeleteCommitmentTask(
    DeleteCommitmentTaskEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    emit(CommitmentTaskLoading());
    try {
      await _repository.deleteCommitmentTask(event.taskVO);

      if (updateAppBar != null) {
        updateAppBar!();
      }

      emit(CommitmentTaskUpdated('Successfully deleted task'));
      add(LoadCommitmentTasksEvent());
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }

  Future<void> _onLoadMoreCommitmentTasks(
    LoadMoreCommitmentTasksEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    // Only support lazy loading for completed tasks
    if (!event.isDone) return;

    // Don't load more if already loading or no more data
    if (state is! CommitmentTaskLoaded) return;

    final currentState = state as CommitmentTaskLoaded;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    try {
      // Set loading state
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = currentState.currentPage + 1;
      final offset = (nextPage - 1) * currentState.pageSize;

      // Load next page of completed tasks
      final newTasks = await _repository.getCommitmentTasks(
        true,
        limit: currentState.pageSize,
        offset: offset,
      );

      if (newTasks.isEmpty) {
        // No more data
        emit(currentState.copyWith(hasMore: false, isLoadingMore: false));
        return;
      }

      // Append new completed tasks
      final allTasks = [...currentState.tasks, ...newTasks];

      emit(
        currentState.copyWith(
          tasks: allTasks,
          currentPage: nextPage,
          hasMore: newTasks.length == currentState.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      emit(CommitmentTaskError(e.toString()));
    }
  }
}
