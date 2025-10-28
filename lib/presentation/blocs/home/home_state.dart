import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ListSavingVO> dailyUsageSavings;
  final List<ListSavingVO> creditSavings;

  const HomeLoaded({
    required this.dailyUsageSavings,
    required this.creditSavings,
  });

  @override
  List<Object> get props => [dailyUsageSavings, creditSavings];
}

class TransactionFormLoaded extends HomeState {
  final List<ListSavingVO> allSavings;

  const TransactionFormLoaded({required this.allSavings});

  @override
  List<Object> get props => [allSavings];
}

class TransactionSuccess extends HomeState {
  final String message;

  const TransactionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}