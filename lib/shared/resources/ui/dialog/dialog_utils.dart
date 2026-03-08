import 'package:flutter/material.dart';
import 'package:wise_spends/shared/resources/ui/dialog/custom_dialog.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

/// Show a simple confirmation dialog
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  IconData? icon,
  Color? iconColor,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool autoClose = true,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        message: message,
        content: content,
        icon: icon ?? Icons.help_outline,
        iconColor: iconColor ?? AppColors.primary,
        buttons: [
          CustomDialogButton(
            text: cancelText,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, false);
              onCancel?.call();
            },
          ),
          CustomDialogButton(
            text: confirmText,
            isDefault: true,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, true);
              onConfirm?.call();
            },
          ),
        ],
      ),
    ),
  );
}

/// Show a delete confirmation dialog
Future<bool?> showDeleteDialog({
  required BuildContext context,
  String title = 'Delete',
  String? message,
  Widget? content,
  String deleteText = 'Delete',
  String cancelText = 'Cancel',
  bool autoDisplayMessage = true,
  VoidCallback? onDelete,
  VoidCallback? onCancel,
  bool autoClose = true,
}) {
  // Capture the root navigator context BEFORE entering the dialog builder.
  // The outer `context` may be a dialog or overlay context itself, so we
  // walk up to the root to get a stable context for snackbars shown AFTER
  // the dialog has been popped (at which point `dialogContext` is gone and
  // the original `context` could also be unmounted).
  final snackBarContext = Navigator.of(context, rootNavigator: true).context;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        message: message ?? 'Are you sure you want to delete this?',
        content: content,
        icon: Icons.delete_outline,
        iconColor: AppColors.secondary,
        buttons: [
          CustomDialogButton(
            text: cancelText,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, false);
              onCancel?.call();
              // Use the stable root context, not dialogContext (already popped)
              // or the outer context (may be unmounted).
              if (autoDisplayMessage && snackBarContext.mounted) {
                showSnackBarMessage(
                  snackBarContext,
                  'Delete cancelled',
                  type: SnackBarMessageType.info,
                );
              }
            },
          ),
          CustomDialogButton(
            text: deleteText,
            isDestructive: true,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, true);
              onDelete?.call();
              if (autoDisplayMessage && snackBarContext.mounted) {
                showSnackBarMessage(
                  snackBarContext,
                  'Successfully deleted',
                  type: SnackBarMessageType.success,
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}

/// Show an information dialog
Future<void> showInfoDialog({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  String okText = 'OK',
  IconData? icon,
  Color? iconColor,
  VoidCallback? onOk,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        message: message,
        content: content,
        icon: icon ?? Icons.info_outline,
        iconColor: iconColor ?? AppColors.info,
        buttons: [
          CustomDialogButton(
            text: okText,
            isDefault: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              onOk?.call();
            },
          ),
        ],
      ),
    ),
  );
}

/// Show a warning dialog
Future<bool?> showWarningDialog({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  String confirmText = 'Proceed',
  String cancelText = 'Cancel',
  IconData? icon,
  Color? iconColor,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool autoClose = true,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        message: message,
        content: content,
        icon: icon ?? Icons.warning_amber_rounded,
        iconColor: iconColor ?? AppColors.warning,
        buttons: [
          CustomDialogButton(
            text: cancelText,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, false);
              onCancel?.call();
            },
          ),
          CustomDialogButton(
            text: confirmText,
            isDefault: true,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, true);
              onConfirm?.call();
            },
          ),
        ],
      ),
    ),
  );
}

/// Show an error dialog
Future<void> showErrorDialog({
  required BuildContext context,
  String title = 'Error',
  required String message,
  Widget? content,
  String okText = 'OK',
  VoidCallback? onOk,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        message: message,
        content: content,
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        buttons: [
          CustomDialogButton(
            text: okText,
            isDefault: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              onOk?.call();
            },
          ),
        ],
      ),
    ),
  );
}

/// Show a success dialog
Future<void> showSuccessDialog({
  required BuildContext context,
  String title = 'Success',
  String? message,
  Widget? content,
  String okText = 'OK',
  VoidCallback? onOk,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        message: message,
        content: content,
        icon: Icons.check_circle_outline,
        iconColor: AppColors.success,
        buttons: [
          CustomDialogButton(
            text: okText,
            isDefault: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              onOk?.call();
            },
          ),
        ],
      ),
    ),
  );
}

/// Show a dialog with a single choice (Yes/No)
Future<bool?> showChoiceDialog({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  String yesText = 'Yes',
  String noText = 'No',
  IconData? icon,
  Color? iconColor,
  bool autoClose = true,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        message: message,
        content: content,
        icon: icon,
        iconColor: iconColor,
        buttons: [
          CustomDialogButton(
            text: noText,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, false);
            },
          ),
          CustomDialogButton(
            text: yesText,
            isDefault: true,
            onPressed: () {
              if (autoClose) Navigator.pop(dialogContext, true);
            },
          ),
        ],
      ),
    ),
  );
}

/// DialogAction helper for showCustomContentDialog
class DialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const DialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  CustomDialogButton toCustomDialogButton() {
    return CustomDialogButton(
      text: text,
      onPressed: onPressed,
      isDefault: isPrimary,
      isDestructive: isDestructive,
    );
  }
}

/// Show a dialog with custom content and actions
Future<T?> showCustomContentDialog<T>({
  required BuildContext context,
  String? title,
  Widget? titleWidget,
  String? message,
  required Widget content,
  List<DialogAction> actions = const [
    DialogAction(text: 'OK', isPrimary: true),
  ],
  IconData? icon,
  Color? iconColor,
  bool isScrollable = true,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: title,
        titleWidget: titleWidget,
        message: message,
        content: content,
        icon: icon,
        iconColor: iconColor,
        isScrollable: isScrollable,
        buttons: actions.map((a) => a.toCustomDialogButton()).toList(),
      ),
    ),
  );
}

/// Show a loading/progress dialog
void showLoadingDialog(
  BuildContext context, {
  String? message,
  bool barrierDismissible = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        buttons: [],
      ),
    ),
  );
}
