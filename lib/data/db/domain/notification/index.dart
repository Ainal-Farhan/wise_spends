import 'package:wise_spends/data/db/domain/notification/notification_table.dart';

export './notification_table.dart';

abstract class Notification {
  static const List<dynamic> tableList = [NotificationTable];
}
