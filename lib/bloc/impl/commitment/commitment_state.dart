part of 'commitment_bloc.dart';

sealed class CommitmentState extends Equatable {
  const CommitmentState();

  @override
  List<Object> get props => [];
}

abstract class CommitmentStateWithMessage extends CommitmentState {
  final String message;
  const CommitmentStateWithMessage(this.message);

  @override
  List<Object> get props => [message];
}

class CommitmentStateInitial extends CommitmentState {
  const CommitmentStateInitial();
}

class CommitmentStateLoading extends CommitmentState {
  const CommitmentStateLoading();
}

class CommitmentStateError extends CommitmentStateWithMessage {
  const CommitmentStateError(super.message);
}

class CommitmentStateSuccess extends CommitmentStateWithMessage {
  const CommitmentStateSuccess(super.message);
}

class CommitmentStateCommitmentsLoaded extends CommitmentState {
  final List<CommitmentVO> commitments;

  const CommitmentStateCommitmentsLoaded(this.commitments);

  @override
  List<Object> get props => [commitments];
}

class CommitmentStateCommitmentDetailLoaded extends CommitmentState {
  final List<CommitmentDetailVO> commitmentDetails;
  final String commitmentId;

  const CommitmentStateCommitmentDetailLoaded(
    this.commitmentDetails,
    this.commitmentId,
  );

  @override
  List<Object> get props => [commitmentDetails, commitmentId];
}

class CommitmentStateCommitmentFormLoaded extends CommitmentState {
  final CommitmentVO commitmentVO;
  final List<ListSavingVO> savingVOList;

  const CommitmentStateCommitmentFormLoaded(
    this.commitmentVO,
    this.savingVOList,
  );

  @override
  List<Object> get props => [commitmentVO, savingVOList];
}

class CommitmentStateCommitmentDetailFormLoaded extends CommitmentState {
  final CommitmentDetailVO commitmentDetailVO;
  final List<ListSavingVO> savingVOList;
  final String? commitmentId;

  const CommitmentStateCommitmentDetailFormLoaded(
    this.commitmentDetailVO,
    this.savingVOList,
    this.commitmentId,
  );

  @override
  List<Object> get props => [
    commitmentDetailVO,
    savingVOList,
    commitmentId ?? '',
  ];
}

extension CommitmentStateX on CommitmentState {
  static CommitmentState initial() => const CommitmentStateInitial();
  static CommitmentState loading() => const CommitmentStateLoading();
  static CommitmentState error(String message) => CommitmentStateError(message);
  static CommitmentState success(String message) =>
      CommitmentStateSuccess(message);
  static CommitmentState commitmentsLoaded(List<CommitmentVO> commitments) =>
      CommitmentStateCommitmentsLoaded(commitments);
  static CommitmentState commitmentDetailLoaded(
    List<CommitmentDetailVO> commitmentDetails,
    String commitmentId,
  ) => CommitmentStateCommitmentDetailLoaded(commitmentDetails, commitmentId);
  static CommitmentState commitmentFormLoaded(
    CommitmentVO commitmentVO,
    List<ListSavingVO> savingVOList,
  ) => CommitmentStateCommitmentFormLoaded(commitmentVO, savingVOList);
  static CommitmentState commitmentDetailFormLoaded(
    CommitmentDetailVO commitmentDetailVO,
    List<ListSavingVO> savingVOList,
    String? commitmentId,
  ) => CommitmentStateCommitmentDetailFormLoaded(
    commitmentDetailVO,
    savingVOList,
    commitmentId,
  );
}
