import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/commitment_task_repository.dart';
import 'commitment_task_event.dart';
import 'commitment_task_state.dart';

class CommitmentTaskBloc extends Bloc<CommitmentTaskEvent, CommitmentTaskState> {
  final ICommitmentTaskRepository _repository;

  CommitmentTaskBloc(this._repository) : super(CommitmentTaskInitial()) {
    on<LoadCommitmentTasksEvent>(_onLoadCommitmentTasks);
    on<UpdateStatusCommitmentTaskEvent>(_onUpdateStatusCommitmentTask);
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
      emit(CommitmentTaskUpdated('Successfully updated task status'));
      // Reload the tasks after update
      add(LoadCommitmentTasksEvent());
    } catch (e) {
      emit(CommitmentTaskError(e.toString()));
    }
  }
}