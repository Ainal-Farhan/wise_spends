import 'package:flutter/material.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Enhanced Notifications Screen
/// Features:
/// - Empty state when no notifications
/// - Notification list with icons and timestamps
/// - Mark as read/unread functionality
/// - Clear all option
/// - Grouped by date
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual notification data from BLoC
    final notifications = <NotificationItem>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                // Clear all notifications
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyNotificationsState()
          : _buildNotificationsList(notifications),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () {
        // Handle notification tap
      },
      child: Row(
        children: [
          Container(
            width: AppTouchTarget.min,
            height: AppTouchTarget.min,
            decoration: BoxDecoration(
              color: _getNotificationColor(
                notification.type,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  notification.message,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatTimeAgo(notification.timestamp),
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: AppSpacing.sm,
              height: AppSpacing.sm,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.error:
        return AppColors.secondary;
      case NotificationType.info:
        return AppColors.info;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'No notifications yet',
      subtitle: 'You\'re all caught up! Notifications will appear here',
      iconColor: AppColors.info,
    );
  }
}

/// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

/// Notification type enum
enum NotificationType { success, warning, error, info }
