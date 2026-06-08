import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {}

class MarkReadEvent extends NotificationsEvent {
  final String id;
  const MarkReadEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class MarkAllReadEvent extends NotificationsEvent {}

class DeleteNotificationEvent extends NotificationsEvent {
  final String id;
  const DeleteNotificationEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearAllNotificationsEvent extends NotificationsEvent {}
