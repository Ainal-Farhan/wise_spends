part of 'commitment_bloc.dart';

abstract class CommitmentState extends Equatable {
  const CommitmentState();

  @override
  List<Object?> get props => [];
}

class CommitmentStateInitial extends CommitmentState {}

class CommitmentStateLoading extends CommitmentState {}

/// Commitment list screen state
class CommitmentStateCommitmentsLoaded extends CommitmentState {
  final List<CommitmentVO> commitments;

  const CommitmentStateCommitmentsLoaded(this.commitments);

  @override
  List<Object?> get props => [commitments];
}

/// Detail screen state — carries detail list, savings list, payee list, and
/// the full commitmentVO (which includes referredSavingVO needed for distribution).
class CommitmentStateDetailScreenReady extends CommitmentState {
  final List<CommitmentDetailVO> commitmentDetails;
  final List<ListSavingVO> savingVOList;

  /// Payee list for the CommitmentDetailForm third-party payment picker.
  final List<PayeeVO> payeeVOList;

  final String commitmentId;

  /// Full commitment VO including referredSavingVO — required for distribution.
  final CommitmentVO? commitmentVO;

  const CommitmentStateDetailScreenReady({
    required this.commitmentDetails,
    required this.savingVOList,
    required this.payeeVOList,
    required this.commitmentId,
    this.commitmentVO,
  });

  @override
  List<Object?> get props => [
    commitmentDetails,
    savingVOList,
    payeeVOList,
    commitmentId,
    commitmentVO,
  ];
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

class CommitmentStateSuccess extends CommitmentState {
  final String message;
  final CommitmentEvent nextEvent;

  const CommitmentStateSuccess(this.message, this.nextEvent);

  @override
  List<Object?> get props => [message, nextEvent];
}

/// Emitted after a successful distribute so the listener can navigate to
/// CommitmentTaskScreen and show the result message.
class CommitmentStateDistributionSuccess extends CommitmentState {
  final String message;
  final String commitmentId;

  const CommitmentStateDistributionSuccess(this.message, this.commitmentId);

  @override
  List<Object?> get props => [message, commitmentId];
}

class CommitmentStateError extends CommitmentState {
  final String message;

  const CommitmentStateError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Factory extension — keeps construction centralised.
extension CommitmentStateX on CommitmentState {
  static CommitmentState initial() => CommitmentStateInitial();
  static CommitmentState loading() => CommitmentStateLoading();

  static CommitmentState commitmentsLoaded(List<CommitmentVO> list) =>
      CommitmentStateCommitmentsLoaded(list);

  static CommitmentState detailScreenReady({
    required List<CommitmentDetailVO> details,
    required List<ListSavingVO> savings,
    required List<PayeeVO> payees,
    required String commitmentId,
    CommitmentVO? commitmentVO,
  }) => CommitmentStateDetailScreenReady(
    commitmentDetails: details,
    savingVOList: savings,
    payeeVOList: payees,
    commitmentId: commitmentId,
    commitmentVO: commitmentVO,
  );

  static CommitmentState commitmentFormLoaded(
    CommitmentVO vo,
    List<ListSavingVO> savings,
  ) => CommitmentStateCommitmentFormLoaded(vo, savings);

  static CommitmentState success(String message, CommitmentEvent next) =>
      CommitmentStateSuccess(message, next);

  static CommitmentState distributionSuccess(
    String message,
    String commitmentId,
  ) => CommitmentStateDistributionSuccess(message, commitmentId);

  static CommitmentState error(String message) => CommitmentStateError(message);
}
