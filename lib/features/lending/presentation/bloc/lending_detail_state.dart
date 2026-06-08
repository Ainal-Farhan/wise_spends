import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';

abstract class LendingDetailState extends Equatable {
  const LendingDetailState();

  @override
  List<Object?> get props => [];
}

class LendingDetailLoading extends LendingDetailState {}

class LendingDetailLoaded extends LendingDetailState {
  final LndngLending lending;
  final List<LndngRepayment> repayments;
  final double outstanding;

  const LendingDetailLoaded({
    required this.lending,
    required this.repayments,
    required this.outstanding,
  });

  @override
  List<Object?> get props => [lending, repayments, outstanding];
}

class LendingDetailError extends LendingDetailState {
  final String message;

  const LendingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
