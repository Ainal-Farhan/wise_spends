import 'package:flutter/material.dart';

enum SnackBarMessageType { success, error, warning, info, normal }

void showSnackBarMessage(
  BuildContext context,
  String message, {
  SnackBarMessageType type = SnackBarMessageType.normal,
}) {
  Color backgroundColor;
  IconData icon;

  switch (type) {
    case SnackBarMessageType.success:
case SnackBarMessageType.info:
      backgroundColor = Theme.of(context).colorScheme.primary;
      icon = Icons.check_circle;
      break;
    case SnackBarMessageType.error:
      backgroundColor = Theme.of(context).colorScheme.error;
      icon = Icons.error_outline;
      break;
    case SnackBarMessageType.warning:
      backgroundColor = Theme.of(context).colorScheme.tertiary;
      icon = Icons.warning_rounded;
      break;
    case SnackBarMessageType.normal:
      backgroundColor = Theme.of(context).colorScheme.onSurface;
      icon = Icons.info_outline;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
