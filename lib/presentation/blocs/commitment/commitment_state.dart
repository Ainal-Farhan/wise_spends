part of 'commitment_bloc.dart';

abstract class CommitmentState extends Equatable {
  const CommitmentState();

  @override
  List<Object?> get props => [];
}

/// Unified state that always carries savings list alongside its primary data.
/// This eliminates the race condition where LoadCommitmentFormEvent and
/// LoadCommitmentDetailEvent would overwrite each other's emitted state.
class CommitmentStateInitial extends CommitmentState {}

class CommitmentStateLoading extends CommitmentState {}

/// Commitment list screen state
class CommitmentStateCommitmentsLoaded extends CommitmentState {
  final List<CommitmentVO> commitments;

  const CommitmentStateCommitmentsLoaded(this.commitments);

  @override
  List<Object?> get props => [commitments];
}

/// Detail screen state — carries BOTH detail list AND savings list.
/// Previously these were two separate states (CommitmentStateCommitmentFormLoaded
/// and CommitmentStateCommitmentDetailLoaded), which caused the race condition:
/// whichever event resolved last would overwrite the other's state, leaving
/// either the savings list or the detail list missing.
class CommitmentStateDetailScreenReady extends CommitmentState {
  final List<CommitmentDetailVO> commitmentDetails;
  final List<ListSavingVO> savingVOList;
  final String commitmentId;
  final CommitmentVO? commitmentVO;

  const CommitmentStateDetailScreenReady({
    required this.commitmentDetails,
    required this.savingVOList,
    required this.commitmentId,
    this.commitmentVO,
  });

  @override
  List<Object?> get props => [commitmentDetails, savingVOList, commitmentId, commitmentVO];
}

/// Form screen state (add/edit commitment)
class CommitmentStateCommitmentFormLoaded extends CommitmentState {
  final CommitmentVO commitmentVO;
  final List<ListSavingVO> savingVOList;

  const CommitmentStateCommitmentFormLoaded(
    this.commitmentVO,
    this.savingVOList,
  );

  @override
  List<Object?> get props => [commitmentVO, savingVOList];
}

/// Distribution success state - triggers navigation to Commitment Task screen
class CommitmentStateDistributionSuccess extends CommitmentState {
  final String message;
  final String commitmentId;

  const CommitmentStateDistributionSuccess(this.message, this.commitmentId);

  @override
  List<Object?> get props => [message, commitmentId];
}

class CommitmentStateSuccess extends CommitmentState {
  final String message;
  final CommitmentEvent nextEvent;

  const CommitmentStateSuccess(this.message, this.nextEvent);

  @override
  List<Object?> get props => [message, nextEvent];
}

class CommitmentStateError extends CommitmentState {
  final String message;

  const CommitmentStateError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Factory extension — keeps construction centralised so call sites
/// don't need to know which concrete class to instantiate.
extension CommitmentStateX on CommitmentState {
  static CommitmentState initial() => CommitmentStateInitial();
  static CommitmentState loading() => CommitmentStateLoading();

  static CommitmentState commitmentsLoaded(List<CommitmentVO> list) =>
      CommitmentStateCommitmentsLoaded(list);

  /// Single factory for the detail screen — always includes savings list.
  static CommitmentState detailScreenReady({
    required List<CommitmentDetailVO> details,
    required List<ListSavingVO> savings,
    required String commitmentId,
    CommitmentVO? commitmentVO,
  }) => CommitmentStateDetailScreenReady(
    commitmentDetails: details,
    savingVOList: savings,
    commitmentId: commitmentId,
    commitmentVO: commitmentVO,
  );

  static CommitmentState commitmentFormLoaded(
    CommitmentVO vo,
    List<ListSavingVO> savings,
  ) => CommitmentStateCommitmentFormLoaded(vo, savings);

  static CommitmentState distributionSuccess(String message, String commitmentId) =>
      CommitmentStateDistributionSuccess(message, commitmentId);

  static CommitmentState success(String message, CommitmentEvent next) =>
      CommitmentStateSuccess(message, next);

  static CommitmentState error(String message) => CommitmentStateError(message);
}
