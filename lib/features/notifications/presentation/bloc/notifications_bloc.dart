import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/notifications/data/repositories/i_notification_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final INotificationRepository _repo;
  StreamSubscription? _sub;

  NotificationsBloc(this._repo) : super(NotificationsLoading()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<MarkReadEvent>(_onMarkRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<DeleteNotificationEvent>(_onDelete);
    on<ClearAllNotificationsEvent>(_onClearAll);
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    await _sub?.cancel();
    await emit.forEach(
      _repo.watchAll(),
      onData: (notifications) {
        final unread = notifications.where((n) => !n.isRead).length;
        return NotificationsLoaded(
          notifications: notifications,
          unreadCount: unread,
        );
      },
      onError: (e, _) => NotificationsError(e.toString()),
    );
  }

  Future<void> _onMarkRead(
    MarkReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repo.markAsRead(event.id);
  }

  Future<void> _onMarkAllRead(
    MarkAllReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repo.markAllAsRead();
  }

  Future<void> _onDelete(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repo.deleteNotification(event.id);
  }

  Future<void> _onClearAll(
    ClearAllNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repo.deleteAllNotifications();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
