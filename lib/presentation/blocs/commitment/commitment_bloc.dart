import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/expense/payee_vo.dart';
import 'package:wise_spends/domain/usecases/i_commitment_manager.dart';
import 'package:wise_spends/domain/usecases/i_payee_manager.dart';
import 'package:wise_spends/domain/usecases/i_saving_manager.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

part 'commitment_event.dart';
part 'commitment_state.dart';

class CommitmentBloc extends Bloc<CommitmentEvent, CommitmentState> {
  final ICommitmentManager _commitmentManager;
  final ISavingManager _savingManager;
  final IPayeeManager _payeeManager;
  Function? updateAppBar;

  CommitmentBloc({
    ICommitmentManager? commitmentManager,
    ISavingManager? savingManager,
    IPayeeManager? payeeManager,
  }) : _commitmentManager =
           commitmentManager ??
           SingletonUtil.getSingleton<IManagerLocator>()!
               .getCommitmentManager(),
       _savingManager =
           savingManager ??
           SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager(),
       _payeeManager =
           payeeManager ??
           SingletonUtil.getSingleton<IManagerLocator>()!.getPayeeManager(),
       super(CommitmentStateX.initial()) {
    on<LoadCommitmentsEvent>(_onLoadCommitments);
    on<LoadDetailScreenEvent>(_onLoadDetailScreen);
    on<LoadCommitmentFormEvent>(_onLoadCommitmentForm);
    on<SaveCommitmentEvent>(_onSaveCommitment);
    on<SaveCommitmentDetailEvent>(_onSaveCommitmentDetail);
    on<DeleteCommitmentEvent>(_onDeleteCommitment);
    on<DeleteCommitmentDetailEvent>(_onDeleteCommitmentDetail);
    on<EditCommitmentEvent>(_onEditCommitment);
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

  /// Fetches savings, commitment details, and payees in parallel so the detail
  /// form can render all three pickers (source saving, target saving, payee)
  /// without a second round-trip.
  Future<void> _onLoadDetailScreen(
    LoadDetailScreenEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      final results = await Future.wait([
        _savingManager.loadListSavingVOList(),
        _commitmentManager.retrieveCommitmentVOBasedOnCommitmentId(
          event.commitmentId,
        ),
        _payeeManager.loadPayeeVOList(),
      ]);

      final savings = results[0] as List<ListSavingVO>;
      final commitment = results[1] as CommitmentVO?;
      final payees = results[2] as List<PayeeVO>;

      emit(
        CommitmentStateX.detailScreenReady(
          details: commitment?.commitmentDetailVOList ?? [],
          savings: savings,
          payees: payees,
          commitmentId: event.commitmentId,
          commitmentVO: commitment,
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

  Future<void> _onSaveCommitment(
    SaveCommitmentEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      await _commitmentManager.saveCommitmentVO(event.commitmentVO);
      emit(
        CommitmentStateX.success(
          'Successfully saved commitment',
          const LoadCommitmentsEvent(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
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
      emit(
        CommitmentStateX.success(
          'Successfully saved commitment detail',
          LoadDetailScreenEvent(event.commitmentId),
        ),
      );
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
      emit(
        CommitmentStateX.success(
          'Successfully deleted commitment',
          const LoadCommitmentsEvent(),
        ),
      );
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
      emit(
        CommitmentStateX.success(
          'Successfully deleted commitment detail',
          LoadDetailScreenEvent(event.commitmentId),
        ),
      );
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

  Future<void> _onStartDistributeCommitment(
    StartDistributeCommitmentEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentStateX.loading());
    try {
      final message = await _commitmentManager.startDistributeCommitment(
        event.commitment,
      );

      if (updateAppBar != null) updateAppBar!();

      emit(
        CommitmentStateX.distributionSuccess(
          message,
          event.commitment.commitmentId ?? '',
        ),
      );
    } catch (e) {
      emit(CommitmentStateX.error(e.toString()));
    }
  }
}
