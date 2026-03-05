import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_task_vo.dart';

abstract class CommitmentTaskState extends Equatable {
  const CommitmentTaskState();

  @override
  List<Object?> get props => [];
}

class CommitmentTaskInitial extends CommitmentTaskState {}

class CommitmentTaskLoading extends CommitmentTaskState {}

class CommitmentTaskLoaded extends CommitmentTaskState {
  final List<CommitmentTaskVO> tasks;
  final String filterStatus;

  const CommitmentTaskLoaded(this.tasks, {this.filterStatus = 'all'});

  @override
  List<Object?> get props => [tasks, filterStatus];

  CommitmentTaskLoaded copyWith({
    List<CommitmentTaskVO>? tasks,
    String? filterStatus,
  }) {
    return CommitmentTaskLoaded(
      tasks ?? this.tasks,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
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
