/// Dialog utilities for WiseSpends application
/// 
/// This library provides standardized dialog functions for common use cases.
/// All dialogs use the CustomDialog widget for consistent UI/UX.
/// 
/// Usage:
/// ```dart
/// // Simple confirm dialog
/// await showConfirmDialog(
///   context: context,
///   title: 'Delete Item',
///   message: 'Are you sure you want to delete this item?',
///   onConfirm: () {
///     // Handle confirmation
///   },
/// );
/// 
/// // Custom content dialog
/// await showDialog(
///   context: context,
///   builder: (context) => CustomDialog(
///     config: CustomDialogConfig(
///       title: 'Custom Title',
///       content: YourCustomWidget(),
///       buttons: [...],
///     ),
///   ),
/// );
/// ```

library;

export 'custom_dialog.dart';
export 'dialog_utils.dart';
