import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wise_spends/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:wise_spends/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getNotificationRepository();
    return BlocProvider(
      create: (_) =>
          NotificationsBloc(repo)..add(LoadNotificationsEvent()),
      child: const _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                return PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'mark_all') {
                      context
                          .read<NotificationsBloc>()
                          .add(MarkAllReadEvent());
                    } else if (v == 'clear_all') {
                      _confirmClearAll(context);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'mark_all',
                      child: Row(
                        children: [
                          Icon(Icons.done_all_rounded),
                          SizedBox(width: 8),
                          Text('Mark all as read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep_rounded),
                          SizedBox(width: 8),
                          Text('Clear all'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationsError) {
            return Center(child: Text(state.message));
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _EmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                return _NotificationTile(
                  notification: state.notifications[index],
                  onTap: () {
                    context.read<NotificationsBloc>().add(
                      MarkReadEvent(state.notifications[index].id),
                    );
                    _handleNotificationTap(
                      context,
                      state.notifications[index],
                    );
                  },
                  onDismiss: () {
                    context.read<NotificationsBloc>().add(
                      DeleteNotificationEvent(state.notifications[index].id),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Remove all notifications? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<NotificationsBloc>()
                  .add(ClearAllNotificationsEvent());
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
  ) {
    switch (notification.type) {
      case 'loan':
        Navigator.pushNamed(context, AppRoutes.loans);
      case 'lending':
        Navigator.pushNamed(context, AppRoutes.lendings);
      case 'credit_card':
        Navigator.pushNamed(context, AppRoutes.creditCards);
      case 'budget':
        Navigator.pushNamed(context, AppRoutes.budgetList);
      case 'commitment':
        Navigator.pushNamed(context, AppRoutes.commitment);
      default:
        break;
    }
  }
}

// ── Notification tile ──────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(Icons.delete_rounded, color: cs.onError),
      ),
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: isUnread
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeIcon(type: notification.type, isUnread: isUnread),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin:
                                  const EdgeInsets.only(left: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatDate(notification.receivedAt),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dt);
  }
}

class _TypeIcon extends StatelessWidget {
  final String type;
  final bool isUnread;

  const _TypeIcon({required this.type, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color) = switch (type) {
      'loan' => (Icons.handshake_outlined, cs.tertiary),
      'lending' => (Icons.volunteer_activism_outlined, cs.primary),
      'credit_card' => (Icons.credit_card_rounded, cs.secondary),
      'budget' => (Icons.pie_chart_outline_rounded, cs.primary),
      'commitment' => (Icons.event_repeat_rounded, cs.tertiary),
      _ => (Icons.notifications_outlined, cs.primary),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isUnread ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No notifications yet',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Push notifications will appear here',
            style: AppTextStyles.bodySmall.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
