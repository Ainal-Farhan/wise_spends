import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';

/// Stores FCM push notifications received by the app so users can review them.
@DataClassName('AppNotification')
class NotificationTable extends BaseEntityTable {
  TextColumn get title => text()();
  TextColumn get body => text()();

  /// JSON string of the FCM message data payload.
  TextColumn get dataJson => text().withDefault(const Constant('{}'))();

  /// Notification category: general, loan, lending, credit_card, budget, commitment
  TextColumn get type => text().withDefault(const Constant('general'))();

  /// FCM message ID
  TextColumn get messageId => text().nullable()();

  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  DateTimeColumn get receivedAt => dateTime()();

  @override
  Map<String, dynamic> toMapFromSubClass() => {
    'title': title.name,
    'body': body.name,
    'dataJson': dataJson.name,
    'type': type.name,
    'messageId': messageId.name,
    'isRead': isRead.name,
    'receivedAt': receivedAt.name,
  };
}
