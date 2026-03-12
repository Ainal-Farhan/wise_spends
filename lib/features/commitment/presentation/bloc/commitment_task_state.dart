import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';

abstract class CommitmentTaskState extends Equatable {
  const CommitmentTaskState();

  @override
  List<Object?> get props => [];
}

class CommitmentTaskInitial extends CommitmentTaskState {}

class CommitmentTaskLoading extends CommitmentTaskState {}

class CommitmentTaskLoaded extends CommitmentTaskState {
  final List<CommitmentTaskVO> tasks;
  final List<ListSavingVO> savingVOList;
  final List<PayeeVO> payeeVOList;
  final String filterStatus;

  const CommitmentTaskLoaded(
    this.tasks,
    this.savingVOList,
    this.payeeVOList, {
    this.filterStatus = 'all',
  });

  @override
  List<Object?> get props => [tasks, savingVOList, payeeVOList, filterStatus];

  CommitmentTaskLoaded copyWith({
    List<CommitmentTaskVO>? tasks,
    List<ListSavingVO>? savingVOList,
    List<PayeeVO>? payeeVOList,
    String? filterStatus,
  }) {
    return CommitmentTaskLoaded(
      tasks ?? this.tasks,
      savingVOList ?? this.savingVOList,
      payeeVOList ?? this.payeeVOList,
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

class CommitmentTaskFormReady extends CommitmentTaskState {
  final CommitmentTaskVO? taskVO;

  const CommitmentTaskFormReady({this.taskVO});

  @override
  List<Object?> get props => [taskVO];

  CommitmentTaskFormReady copyWith({CommitmentTaskVO? taskVO}) {
    return CommitmentTaskFormReady(taskVO: taskVO ?? this.taskVO);
  }
}
