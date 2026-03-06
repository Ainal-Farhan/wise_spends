part of 'commitment_bloc.dart';

abstract class CommitmentEvent extends Equatable {
  const CommitmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCommitmentsEvent extends CommitmentEvent {
  const LoadCommitmentsEvent();
}

/// Unified event that replaces the two-event pattern:
///   add(LoadCommitmentFormEvent())       // loaded savings → state A
///   add(LoadCommitmentDetailEvent(...))  // loaded details → state B (state A lost!)
///
/// Now a single event fetches both in parallel and emits one combined state,
/// so there is no window where one overwrites the other.
class LoadDetailScreenEvent extends CommitmentEvent {
  final String commitmentId;

  const LoadDetailScreenEvent(this.commitmentId);

  @override
  List<Object?> get props => [commitmentId];
}

/// Kept for the add/edit commitment form (not the detail screen).
class LoadCommitmentFormEvent extends CommitmentEvent {
  final CommitmentVO? commitmentVO;

  const LoadCommitmentFormEvent({this.commitmentVO});

  @override
  List<Object?> get props => [commitmentVO];
}

class SaveCommitmentEvent extends CommitmentEvent {
  final CommitmentVO commitmentVO;

  const SaveCommitmentEvent(this.commitmentVO);

  @override
  List<Object?> get props => [commitmentVO];
}

class SaveCommitmentDetailEvent extends CommitmentEvent {
  final String commitmentId;
  final CommitmentDetailVO commitmentDetailVO;

  const SaveCommitmentDetailEvent({
    required this.commitmentId,
    required this.commitmentDetailVO,
  });

  @override
  List<Object?> get props => [commitmentId, commitmentDetailVO];
}

class DeleteCommitmentEvent extends CommitmentEvent {
  final String commitmentId;

  const DeleteCommitmentEvent(this.commitmentId);

  @override
  List<Object?> get props => [commitmentId];
}

class DeleteCommitmentDetailEvent extends CommitmentEvent {
  final String commitmentDetailId;
  final String commitmentId;

  const DeleteCommitmentDetailEvent(
    this.commitmentDetailId, {
    required this.commitmentId,
  });

  @override
  List<Object?> get props => [commitmentDetailId, commitmentId];
}

class EditCommitmentEvent extends CommitmentEvent {
  final CommitmentVO commitmentVO;

  const EditCommitmentEvent(this.commitmentVO);

  @override
  List<Object?> get props => [commitmentVO];
}

class StartDistributeCommitmentEvent extends CommitmentEvent {
  final CommitmentVO commitment;

  const StartDistributeCommitmentEvent(this.commitment);

  @override
  List<Object?> get props => [commitment];
}
