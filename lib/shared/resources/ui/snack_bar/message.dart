import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

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
      backgroundColor = AppColors.success;
      icon = Icons.check_circle;
      break;
    case SnackBarMessageType.error:
      backgroundColor = AppColors.error;
      icon = Icons.error_outline;
      break;
    case SnackBarMessageType.warning:
      backgroundColor = AppColors.warning;
      icon = Icons.warning_amber_rounded;
      break;
    case SnackBarMessageType.info:
      backgroundColor = AppColors.info;
      icon = Icons.info_outline;
      break;
    case SnackBarMessageType.normal:
      backgroundColor = AppColors.textPrimary;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
