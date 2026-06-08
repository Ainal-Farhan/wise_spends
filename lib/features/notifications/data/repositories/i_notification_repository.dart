import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/notification/notification_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class INotificationRepository
    extends
        ICrudRepository<
          NotificationTable,
          $NotificationTableTable,
          NotificationTableCompanion,
          AppNotification
        > {
  INotificationRepository(AppDatabase db) : super(db, db.notificationTable);

  Future<List<AppNotification>> getAllNotifications();
  Future<int> getUnreadCount();
  Future<void> saveNotification({
    required String title,
    required String body,
    required String dataJson,
    required String type,
    String? messageId,
  });
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> deleteAllNotifications();
  Stream<List<AppNotification>> watchAll();
  Stream<int> watchUnreadCount();
}
