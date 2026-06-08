import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/notifications/data/repositories/i_notification_repository.dart';

class NotificationRepository extends INotificationRepository {
  NotificationRepository() : super(AppDatabase());

  @override
  Future<List<AppNotification>> getAllNotifications() {
    return (db.select(db.notificationTable)
          ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
        .get();
  }

  @override
  Future<int> getUnreadCount() async {
    final count = await (db.select(db.notificationTable)
          ..where((t) => t.isRead.equals(false)))
        .get();
    return count.length;
  }

  @override
  Future<void> saveNotification({
    required String title,
    required String body,
    required String dataJson,
    required String type,
    String? messageId,
  }) async {
    final now = DateTime.now();
    await db.into(db.notificationTable).insert(
      NotificationTableCompanion.insert(
        id: Value(UuidGenerator().v4()),
        title: title,
        body: body,
        dataJson: Value(dataJson),
        type: Value(type),
        messageId: Value(messageId),
        isRead: const Value(false),
        receivedAt: now,
        createdBy: 'fcm',
        dateCreated: Value(now),
        dateUpdated: now,
        lastModifiedBy: 'fcm',
      ),
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    final now = DateTime.now();
    await (db.update(db.notificationTable)..where((t) => t.id.equals(id)))
        .write(
          NotificationTableCompanion(
            isRead: const Value(true),
            dateUpdated: Value(now),
            lastModifiedBy: const Value('app'),
          ),
        );
  }

  @override
  Future<void> markAllAsRead() async {
    final now = DateTime.now();
    await db.update(db.notificationTable).write(
      NotificationTableCompanion(
        isRead: const Value(true),
        dateUpdated: Value(now),
        lastModifiedBy: const Value('app'),
      ),
    );
  }

  @override
  Future<void> deleteNotification(String id) async {
    await (db.delete(db.notificationTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteAllNotifications() async {
    await db.delete(db.notificationTable).go();
  }

  @override
  Stream<List<AppNotification>> watchAll() {
    return (db.select(db.notificationTable)
          ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
        .watch();
  }

  @override
  Stream<int> watchUnreadCount() {
    return (db.select(db.notificationTable)
          ..where((t) => t.isRead.equals(false)))
        .watch()
        .map((list) => list.length);
  }

  @override
  String getTypeName() => 'NotificationTable';

  @override
  AppNotification fromJson(Map<String, dynamic> json) =>
      AppNotification.fromJson(json);
}
