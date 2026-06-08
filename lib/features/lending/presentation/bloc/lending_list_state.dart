import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';

class LendingSummary {
  final LndngLending lending;
  final double outstanding;

  const LendingSummary({required this.lending, required this.outstanding});
}

abstract class LendingListState extends Equatable {
  const LendingListState();

  @override
  List<Object?> get props => [];
}

class LendingListLoading extends LendingListState {}

class LendingListLoaded extends LendingListState {
  final List<LendingSummary> summaries;

  const LendingListLoaded(this.summaries);

  @override
  List<Object?> get props => [summaries];
}

class LendingError extends LendingListState {
  final String message;

  const LendingError(this.message);

  @override
  List<Object?> get props => [message];
}
