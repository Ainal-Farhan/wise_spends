import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

/// Custom Dialog Button Configuration
class CustomDialogButton {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const CustomDialogButton({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });

  /// Pre-configured cancel button
  static const cancel = CustomDialogButton(
    text: 'Cancel',
    isDestructive: false,
  );

  /// Pre-configured confirm button (destructive)
  static const confirm = CustomDialogButton(
    text: 'Confirm',
    isDestructive: true,
  );

  /// Pre-configured OK button
  static const ok = CustomDialogButton(
    text: 'OK',
    isDefault: true,
  );
}

/// Custom Dialog Configuration
class CustomDialogConfig {
  final String? title;
  final Widget? titleWidget;
  final String? message;
  final Widget? content;
  final List<CustomDialogButton> buttons;
  final IconData? icon;
  final Color? iconColor;
  final bool isScrollable;
  final double? width;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onDismissed;

  const CustomDialogConfig({
    this.title,
    this.titleWidget,
    this.message,
    this.content,
    this.buttons = const [CustomDialogButton.ok],
    this.icon,
    this.iconColor,
    this.isScrollable = true,
    this.width,
    this.contentPadding,
    this.onDismissed,
  });
}

/// A customizable, standardized dialog widget for WiseSpends
///
/// This dialog provides consistent UI/UX across the application with:
/// - Consistent styling following Material 3 design
/// - Flexible content support (text, widgets, forms)
/// - Configurable button arrangements
/// - Optional icon support
/// - Proper accessibility support
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => CustomDialog(
///     config: CustomDialogConfig(
///       title: 'Delete Item',
///       message: 'Are you sure you want to delete this item?',
///       icon: Icons.delete_outline,
///       iconColor: AppColors.secondary,
///       buttons: [
///         CustomDialogButton(
///           text: 'Cancel',
///           onPressed: () => Navigator.pop(context),
///         ),
///         CustomDialogButton(
///           text: 'Delete',
///           isDestructive: true,
///           onPressed: () {
///             // Delete logic
///             Navigator.pop(context);
///           },
///         ),
///       ],
///     ),
///   ),
/// );
/// ```
class CustomDialog extends StatelessWidget {
  final CustomDialogConfig config;

  const CustomDialog({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: AppElevation.lg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      child: Padding(
        padding: config.contentPadding ??
            const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon (if provided)
            if (config.icon != null) ...[
              Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: (config.iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  color: config.iconColor ?? AppColors.primary,
                  size: 28,
                ),
              ),
            ],

            // Title
            if (config.title != null || config.titleWidget != null) ...[
              config.titleWidget ??
                  Text(
                    config.title!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
              if (config.message != null) const SizedBox(height: AppSpacing.xs),
            ],

            // Message
            if (config.message != null)
              Text(
                config.message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
                ),
              ),

            // Custom content
            if (config.content != null) ...[
              if (config.title != null || config.message != null)
                const SizedBox(height: AppSpacing.md),
              if (config.isScrollable)
                Flexible(
                  child: SingleChildScrollView(
                    child: config.content!,
                  ),
                )
              else
                config.content!,
            ],

            // Buttons
            if (config.buttons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildButtonBar(context, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButtonBar(BuildContext context, ThemeData theme) {
    final buttonCount = config.buttons.length;
    final isSingleButton = buttonCount == 1;

    // Sort buttons: default action first, then others
    final sortedButtons = [...config.buttons]
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return 0;
      });

    if (isSingleButton) {
      // Single button - full width
      return _buildButton(context, sortedButtons.first, isFullWidth: true);
    }

    // Multiple buttons - row layout
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: sortedButtons
          .map((button) => _buildButton(context, button))
          .toList(),
    );
  }

  Widget _buildButton(
    BuildContext context,
    CustomDialogButton button, {
    bool isFullWidth = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (button.isDestructive) {
      // Destructive button (e.g., Delete, Remove)
      return Expanded(
        child: FilledButton(
          onPressed: () {
            button.onPressed?.call();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, AppTouchTarget.min),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: Text(
            button.text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else if (button.isDefault) {
      // Default/primary button
      return Expanded(
        child: FilledButton(
          onPressed: () {
            button.onPressed?.call();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, AppTouchTarget.min),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: Text(
            button.text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else {
      // Secondary/cancel button
      return OutlinedButton(
        onPressed: () {
          button.onPressed?.call();
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppTouchTarget.min),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Text(
          button.text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
          ),
        ),
      );
    }
  }
}

/// Extension method to show custom dialog easily
extension CustomDialogExtension on BuildContext {
  Future<T?> showCustomDialog<T>({
    required CustomDialogConfig config,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => CustomDialog(config: config),
    );
  }
}
