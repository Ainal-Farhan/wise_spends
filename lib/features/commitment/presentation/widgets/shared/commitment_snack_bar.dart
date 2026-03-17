import 'package:flutter/material.dart';

/// Shows a floating snack bar with an icon, consistent across all
/// commitment screens (success, error, info).
///
/// Example:
/// ```dart
/// showCommitmentSnackBar(
///   context,
///   message: 'Task updated',
///   icon: Icons.check_circle,
///   color: Theme.of(context).colorScheme.primary,
/// );
/// ```
void showCommitmentSnackBar(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color color,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}
