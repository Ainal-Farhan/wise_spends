import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_task_repository.dart';
import 'commitment_task_event.dart';
import 'commitment_task_state.dart';

class CommitmentTaskBloc
    extends Bloc<CommitmentTaskEvent, CommitmentTaskState> {
  final ICommitmentTaskRepository _repository;

  Function? updateAppBar;

  CommitmentTaskBloc(this._repository) : super(CommitmentTaskInitial()) {
    on<LoadCommitmentTasksEvent>(_onLoadCommitmentTasks);
    on<UpdateStatusCommitmentTaskEvent>(_onUpdateStatusCommitmentTask);
    on<FilterCommitmentTasksEvent>(_onFilterCommitmentTasks);
    on<AddCommitmentTaskEvent>(_onAddCommitmentTask);
    on<EditCommitmentTaskEvent>(_onEditCommitmentTask);
    on<DeleteCommitmentTaskEvent>(_onDeleteCommitmentTask);
  }

  Future<void> _onLoadCommitmentTasks(
    LoadCommitmentTasksEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    emit(CommitmentTaskLoading());
    try {
      final tasks = await _repository.getCommitmentTasks();
      emit(CommitmentTaskLoaded(tasks));
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }

  Future<void> _onUpdateStatusCommitmentTask(
    UpdateStatusCommitmentTaskEvent event,
    Emitter<CommitmentTaskState> emit,
  ) async {
    emit(CommitmentTaskLoading());
    try {
      await _repository.updateTaskStatus(event.isDone, event.taskVO);

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
    if (state is CommitmentTaskLoaded) {
      final currentState = state as CommitmentTaskLoaded;
      emit(currentState.copyWith(filterStatus: event.filterStatus));
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
}
