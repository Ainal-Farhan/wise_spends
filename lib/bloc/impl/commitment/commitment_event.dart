part of 'commitment_bloc.dart';

sealed class CommitmentEvent extends Equatable {
  const CommitmentEvent();

  @override
  List<Object> get props => [];
}

class LoadCommitmentsEvent extends CommitmentEvent {
  const LoadCommitmentsEvent();
}

class LoadCommitmentDetailEvent extends CommitmentEvent {
  final String? commitmentId;

  const LoadCommitmentDetailEvent(this.commitmentId);

  @override
  List<Object> get props => [commitmentId ?? ''];
}

class LoadCommitmentFormEvent extends CommitmentEvent {
  final CommitmentVO? commitmentVO;

  const LoadCommitmentFormEvent({this.commitmentVO});

  @override
  List<Object> get props => [if (commitmentVO != null) commitmentVO!];
}

class LoadCommitmentDetailFormEvent extends CommitmentEvent {
  final CommitmentDetailVO? commitmentDetailVO;
  final String commitmentId;

  const LoadCommitmentDetailFormEvent({
    this.commitmentDetailVO,
    required this.commitmentId,
  });

  @override
  List<Object> get props => [
    if (commitmentDetailVO != null) commitmentDetailVO!,
    commitmentId,
  ];
}

class SaveCommitmentEvent extends CommitmentEvent {
  final CommitmentVO commitmentVO;

  const SaveCommitmentEvent(this.commitmentVO);

  @override
  List<Object> get props => [commitmentVO];
}

class SaveCommitmentDetailEvent extends CommitmentEvent {
  final String commitmentId;
  final CommitmentDetailVO commitmentDetailVO;

  const SaveCommitmentDetailEvent({
    required this.commitmentId,
    required this.commitmentDetailVO,
  });

  @override
  List<Object> get props => [commitmentId, commitmentDetailVO];
}

class DeleteCommitmentEvent extends CommitmentEvent {
  final String commitmentId;

  const DeleteCommitmentEvent(this.commitmentId);

  @override
  List<Object> get props => [commitmentId];
}

class DeleteCommitmentDetailEvent extends CommitmentEvent {
  final String commitmentDetailId;

  const DeleteCommitmentDetailEvent(this.commitmentDetailId);

  @override
  List<Object> get props => [commitmentDetailId];
}

class EditCommitmentEvent extends CommitmentEvent {
  final CommitmentVO commitmentVO;

  const EditCommitmentEvent(this.commitmentVO);

  @override
  List<Object> get props => [commitmentVO];
}

class EditCommitmentDetailEvent extends CommitmentEvent {
  final CommitmentDetailVO commitmentDetailVO;
  final String commitmentId;

  const EditCommitmentDetailEvent({
    required this.commitmentDetailVO,
    required this.commitmentId,
  });

  @override
  List<Object> get props => [commitmentDetailVO, commitmentId];
}

class StartDistributeCommitmentEvent extends CommitmentEvent {
  final CommitmentVO commitment;

  const StartDistributeCommitmentEvent(this.commitment);

  @override
  List<Object> get props => [commitment];
}
