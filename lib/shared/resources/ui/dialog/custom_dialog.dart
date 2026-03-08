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

  static const cancel = CustomDialogButton(text: 'Cancel');
  static const confirm = CustomDialogButton(
    text: 'Confirm',
    isDestructive: true,
  );
  static const ok = CustomDialogButton(text: 'OK', isDefault: true);
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

class CustomDialog extends StatelessWidget {
  final CustomDialogConfig config;

  const CustomDialog({super.key, required this.config});

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
        padding:
            config.contentPadding ??
            const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (config.icon != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: (config.iconColor ?? AppColors.primary).withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    config.icon,
                    color: config.iconColor ?? AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ],
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
            if (config.message != null)
              Text(
                config.message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (config.content != null) ...[
              if (config.title != null || config.message != null)
                const SizedBox(height: AppSpacing.md),
              if (config.isScrollable)
                Flexible(child: SingleChildScrollView(child: config.content!))
              else
                config.content!,
            ],
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
    // Sort: non-default (cancel) first, default/destructive last — natural
    // dialog convention (Cancel | OK).
    final sorted = [...config.buttons]
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return 1;
        if (!a.isDefault && b.isDefault) return -1;
        return 0;
      });

    if (sorted.length == 1) {
      return _buildButton(context, sorted.first, expand: true);
    }

    // Multiple buttons — Row so Expanded works correctly.
    return IntrinsicHeight(
      child: Row(
        children: sorted
            .map(
              (btn) =>
                  Expanded(child: _buildButton(context, btn, expand: true)),
            )
            .toList(),
      ),
    );
  }

  /// Builds a single button.
  ///
  /// [expand] makes the button fill its parent's width. When placed inside
  /// an [Expanded] in a [Row], width is already constrained — never use a
  /// bare [Expanded] here since this widget may also be used outside a Flex.
  Widget _buildButton(
    BuildContext context,
    CustomDialogButton button, {
    bool expand = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const buttonHeight = 48.0;

    Widget child = Text(
      button.text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );

    Widget builtButton;

    if (button.isDestructive) {
      builtButton = FilledButton(
        onPressed: button.onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, buttonHeight),
          maximumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: child,
      );
    } else if (button.isDefault) {
      builtButton = FilledButton(
        onPressed: button.onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, buttonHeight),
          maximumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: child,
      );
    } else {
      builtButton = OutlinedButton(
        onPressed: button.onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          maximumSize: const Size(double.infinity, buttonHeight),
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
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // SizedBox constrains height; width expands only when caller wants it.
    return SizedBox(
      height: buttonHeight,
      width: expand ? double.infinity : null,
      child: builtButton,
    );
  }
}

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
