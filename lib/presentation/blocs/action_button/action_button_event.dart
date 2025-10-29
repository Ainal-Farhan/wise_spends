part of 'action_button_bloc.dart';

abstract class ActionButtonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnUpdateActionButtonEvent extends ActionButtonEvent {
  final BuildContext context;
  final Map<ActionButtonEnum, VoidCallback?>? actionButtonMap;

  OnUpdateActionButtonEvent({required this.context, this.actionButtonMap});

  @override
  List<Object?> get props => [actionButtonMap];
}
