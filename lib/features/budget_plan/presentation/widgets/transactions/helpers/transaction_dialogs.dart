import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';

/// Shows a themed delete confirmation dialog and returns the user's choice.
///
/// Usage:
/// ```dart
/// final confirmed = await confirmDelete(context, messageKey: 'budget_plans.delete_deposit_msg');
/// if (confirmed == true && context.mounted) { ... }
/// ```
Future<bool?> confirmDelete(
  BuildContext context, {
  required String messageKey,
}) {
  return showDeleteDialog(
    context: context,
    title: 'general.delete'.tr,
    message: messageKey.tr,
    deleteText: 'general.delete'.tr,
    cancelText: 'general.cancel'.tr,
  );
}
