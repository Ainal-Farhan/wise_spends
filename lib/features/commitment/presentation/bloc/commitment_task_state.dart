import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/commitment/domain/entities/task_group_vo.dart';
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
  final List<TaskGroupVO> groupedTasks;
  final List<CommitmentTaskVO> ungroupedTasks;

  const CommitmentTaskLoaded(
    this.tasks,
    this.savingVOList,
    this.payeeVOList, {
    required this.filterStatus,
    this.groupedTasks = const [],
    this.ungroupedTasks = const [],
  });

  @override
  List<Object?> get props => [
    tasks,
    savingVOList,
    payeeVOList,
    filterStatus,
    groupedTasks,
    ungroupedTasks,
  ];

  CommitmentTaskLoaded copyWith({
    List<CommitmentTaskVO>? tasks,
    List<ListSavingVO>? savingVOList,
    List<PayeeVO>? payeeVOList,
    String? filterStatus,
    List<TaskGroupVO>? groupedTasks,
    List<CommitmentTaskVO>? ungroupedTasks,
  }) {
    return CommitmentTaskLoaded(
      tasks ?? this.tasks,
      savingVOList ?? this.savingVOList,
      payeeVOList ?? this.payeeVOList,
      filterStatus: filterStatus ?? this.filterStatus,
      groupedTasks: groupedTasks ?? this.groupedTasks,
      ungroupedTasks: ungroupedTasks ?? this.ungroupedTasks,
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
