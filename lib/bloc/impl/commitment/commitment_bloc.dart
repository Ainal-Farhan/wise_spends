import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

part 'commitment_event.dart';
part 'commitment_state.dart';

class CommitmentBloc extends Bloc<CommitmentEvent, CommitmentState> {
  final ICommitmentManager _commitmentManager;
  final ISavingManager _savingManager;
  Function? updateAppBar;

  CommitmentBloc({
    ICommitmentManager? commitmentManager,
    ISavingManager? savingManager,
  }) : _commitmentManager =
           commitmentManager ??
           SingletonUtil.getSingleton<IManagerLocator>()!
               .getCommitmentManager(),
       _savingManager =
           savingManager ??
           SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager(),
       super(CommitmentStateX.initial()) {
    on<LoadCommitmentsEvent>(_onLoadCommitments);
    on<LoadCommitmentDetailEvent>(_onLoadCommitmentDetail);
    on<LoadCommitmentFormEvent>(_onLoadCommitmentForm);
    on<LoadCommitmentDetailFormEvent>(_onLoadCommitmentDetailForm);
    on<SaveCommitmentEvent>(_onSaveCommitment);
    on<SaveCommitmentDetailEvent>(_onSaveCommitmentDetail);
    on<DeleteCommitmentEvent>(_onDeleteCommitment);
    on<DeleteCommitmentDetailEvent>(_onDeleteCommitmentDetail);
    on<EditCommitmentEvent>(_onEditCommitment);
    on<EditCommitmentDetailEvent>(_onEditCommitmentDetail);
    on<StartDistributeCommitmentEvent>(_onStartDistributeCommitment);
  }

  Future<void> _onLoadCommitments(
    LoadCommitmentsEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      final commitments = await _commitmentManager
          .retrieveListOfCommitmentOfCurrentUser();
      emit(CommitmentStateX.commitmentsLoaded(commitments));
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onLoadCommitmentDetail(
    LoadCommitmentDetailEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      if (event.commitmentId == null) {
        emit(CommitmentStateX.error('Commitment ID is required'));
        return;
      }

      final commitment = await _commitmentManager
          .retrieveCommitmentVOBasedOnCommitmentId(event.commitmentId!);
      emit(
        CommitmentStateX.commitmentDetailLoaded(
          commitment!.commitmentDetailVOList,
          event.commitmentId!,
        ),
      );
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onLoadCommitmentForm(
    LoadCommitmentFormEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    try {
      final savingVOList = await _savingManager.loadListSavingVOList();
      final commitmentVO = event.commitmentVO ?? CommitmentVO();
      emit(CommitmentStateX.commitmentFormLoaded(commitmentVO, savingVOList));
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onLoadCommitmentDetailForm(
    LoadCommitmentDetailFormEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    try {
      final savingVOList = await _savingManager.loadListSavingVOList();
      final commitmentDetailVO =
          event.commitmentDetailVO ?? CommitmentDetailVO();
      emit(
        CommitmentStateX.commitmentDetailFormLoaded(
          commitmentDetailVO,
          savingVOList,
          event.commitmentId,
        ),
      );
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onSaveCommitment(
    SaveCommitmentEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      await _commitmentManager.saveCommitmentVO(event.commitmentVO);
      emit(CommitmentStateX.success('Successfully saved commitment'));
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onSaveCommitmentDetail(
    SaveCommitmentDetailEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      await _commitmentManager.saveCommitmentDetailVO(event.commitmentId, [
        event.commitmentDetailVO,
      ]);
      emit(CommitmentStateX.success('Successfully saved commitment detail'));
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onDeleteCommitment(
    DeleteCommitmentEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      await _commitmentManager.deleteCommitmentVO(event.commitmentId);
      emit(CommitmentStateX.success('Successfully deleted commitment'));
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onDeleteCommitmentDetail(
    DeleteCommitmentDetailEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      await _commitmentManager.deleteCommitmentDetailVO(
        event.commitmentDetailId,
      );
      emit(CommitmentStateX.success('Successfully deleted commitment detail'));
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }

  Future<void> _onEditCommitment(
    EditCommitmentEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    add(LoadCommitmentFormEvent(commitmentVO: event.commitmentVO));
  }

  Future<void> _onEditCommitmentDetail(
    EditCommitmentDetailEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    add(
      LoadCommitmentDetailFormEvent(
        commitmentDetailVO: event.commitmentDetailVO,
        commitmentId: event.commitmentId,
      ),
    );
  }

  Future<void> _onStartDistributeCommitment(
    StartDistributeCommitmentEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      final message = await _commitmentManager.startDistributeCommitment(
        event.commitment,
      );

      if (updateAppBar != null) {
        updateAppBar!();
      }

      emit(CommitmentStateX.success(message));
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }
}
