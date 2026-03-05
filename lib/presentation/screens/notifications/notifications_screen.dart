import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Notifications Screen - Placeholder for future notification system
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: WiseSpendsColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: WiseSpendsColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifications will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WiseSpendsColors.textHint,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
