import 'package:equatable/equatable.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_task_vo.dart';

abstract class CommitmentTaskEvent extends Equatable {
  const CommitmentTaskEvent();

  @override
  List<Object> get props => [];
}

class LoadCommitmentTasksEvent extends CommitmentTaskEvent {}

class UpdateStatusCommitmentTaskEvent extends CommitmentTaskEvent {
  final bool isDone;
  final CommitmentTaskVO taskVO;

  const UpdateStatusCommitmentTaskEvent(this.isDone, this.taskVO);

  @override
  List<Object> get props => [isDone, taskVO];
}