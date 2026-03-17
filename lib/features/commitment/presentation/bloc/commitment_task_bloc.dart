import 'package:bloc/bloc.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/commitment/data/repositories/i_commitment_task_repository.dart';
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
      final incompleteTasks = await _repository.getCommitmentTasks(false);
      final completedTasks = await _repository.getCommitmentTasks(true);

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

      emit(
        CommitmentTaskLoaded(
          [...incompleteTasks, ...completedTasks],
          savingVOList,
          payeeVOList,
        ),
      );
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
