import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class HomeAppBar extends StatelessWidget {
  final int pendingTaskCount;
  final VoidCallback onMenuTap;

  const HomeAppBar({
    super.key,
    required this.pendingTaskCount,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: _MenuButton(onTap: onMenuTap),
      title: _AppBarTitle(),
      actions: [
        _TasksBadgeButton(pendingTaskCount: pendingTaskCount),
        _NotificationButton(),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      onPressed: onTap,
      tooltip: 'Menu',
      constraints: const BoxConstraints(
        minWidth: AppTouchTarget.min,
        minHeight: AppTouchTarget.min,
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          'WiseSpends',
          style: AppTextStyles.h2.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '${'home.greeting_morning'.tr} 👋';
    if (hour < 17) return '${'home.greeting_afternoon'.tr} 👋';
    return '${'home.greeting_evening'.tr} 👋';
  }
}

class _TasksBadgeButton extends StatelessWidget {
  final int pendingTaskCount;

  const _TasksBadgeButton({required this.pendingTaskCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.task_alt_rounded),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.commitmentTask),
          tooltip: 'Commitment Tasks',
          constraints: const BoxConstraints(
            minWidth: AppTouchTarget.min,
            minHeight: AppTouchTarget.min,
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: _TaskCountBadge(count: pendingTaskCount),
        ),
      ],
    );
  }
}

class _TaskCountBadge extends StatelessWidget {
  final int count;

  const _TaskCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.error,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_outlined),
      onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
      tooltip: 'Notifications',
      constraints: const BoxConstraints(
        minWidth: AppTouchTarget.min,
        minHeight: AppTouchTarget.min,
      ),
    );
  }
}
