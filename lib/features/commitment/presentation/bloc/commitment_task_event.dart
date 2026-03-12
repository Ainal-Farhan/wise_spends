import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';

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

class FilterCommitmentTasksEvent extends CommitmentTaskEvent {
  final String filterStatus;

  const FilterCommitmentTasksEvent(this.filterStatus);

  @override
  List<Object> get props => [filterStatus];
}

class AddCommitmentTaskEvent extends CommitmentTaskEvent {
  final CommitmentTaskVO taskVO;

  const AddCommitmentTaskEvent(this.taskVO);

  @override
  List<Object> get props => [taskVO];
}

class EditCommitmentTaskEvent extends CommitmentTaskEvent {
  final CommitmentTaskVO taskVO;

  const EditCommitmentTaskEvent(this.taskVO);

  @override
  List<Object> get props => [taskVO];
}

class DeleteCommitmentTaskEvent extends CommitmentTaskEvent {
  final CommitmentTaskVO taskVO;

  const DeleteCommitmentTaskEvent(this.taskVO);

  @override
  List<Object> get props => [taskVO];
}