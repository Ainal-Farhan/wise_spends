import 'package:equatable/equatable.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_task_vo.dart';

abstract class CommitmentTaskState extends Equatable {
  const CommitmentTaskState();

  @override
  List<Object?> get props => [];
}

class CommitmentTaskInitial extends CommitmentTaskState {}

class CommitmentTaskLoading extends CommitmentTaskState {}

class CommitmentTaskLoaded extends CommitmentTaskState {
  final List<CommitmentTaskVO> tasks;

  const CommitmentTaskLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class CommitmentTaskUpdated extends CommitmentTaskState {
  final String message;

  const CommitmentTaskUpdated(this.message);

  @override
  List<Object> get props => [message];
}

class CommitmentTaskError extends CommitmentTaskState {
  final String message;

  const CommitmentTaskError(this.message);

  @override
  List<Object> get props => [message];
}