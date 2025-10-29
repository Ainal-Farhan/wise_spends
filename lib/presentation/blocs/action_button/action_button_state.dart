part of 'action_button_bloc.dart';

abstract class ActionButtonState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActionButtonInitialState extends ActionButtonState {}

class ActionButtonsLoaded extends ActionButtonState {
  final List<FloatingActionButton> floatingActionButtonList;

  ActionButtonsLoaded({required this.floatingActionButtonList});

  @override
  List<Object?> get props => [floatingActionButtonList];
}
