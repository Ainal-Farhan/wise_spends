import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Button variants for different use cases
enum AppButtonVariant {
  /// Primary action - filled with primary color
  primary,

  /// Secondary action - outlined
  secondary,

  /// Destructive action - filled with error color
  destructive,

  /// Tonal action - filled with primary container
  tonal,

  /// Text-only action
  text,

  /// Ghost button - no background, with border
  ghost,
}

/// Button sizes
enum AppButtonSize {
  /// Small button - 36dp height
  small,

  /// Medium button - 48dp height (default)
  medium,

  /// Large button - 56dp height
  large,
}

/// WiseSpends AppButton Component
///
/// A standardized button component with consistent styling across the app.
///
/// Features:
/// - Multiple variants (primary, secondary, destructive, tonal, text, ghost)
/// - Multiple sizes (small, medium, large)
/// - Loading state with spinner
/// - Disabled state
/// - Full width or content-sized
/// - Icon support (leading and trailing)
/// - Minimum 48dp touch target
///
/// Usage:
/// ```dart
/// // Primary button
/// AppButton.primary(
///   label: 'Save',
///   onPressed: () {},
/// )
///
/// // Secondary button
/// AppButton.secondary(
///   label: 'Cancel',
///   onPressed: () {},
/// )
///
/// // Destructive button
/// AppButton.destructive(
///   label: 'Delete',
///   onPressed: () {},
/// )
///
/// // Loading state
/// AppButton.primary(
///   label: 'Saving...',
///   isLoading: true,
///   onPressed: null,
/// )
///
/// // With icon
/// AppButton.primary(
///   label: 'Continue',
///   icon: Icons.arrow_forward,
///   onPressed: () {},
/// )
///
/// // Full width
/// AppButton.primary(
///   label: 'Submit',
///   onPressed: () {},
///   isFullWidth: true,
/// )
/// ```
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? trailingIcon;
  final String? tooltip;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.trailingIcon,
    this.tooltip,
    this.width,
  });

  /// Primary variant constructor
  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    IconData? trailingIcon,
    String? tooltip,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      trailingIcon: trailingIcon,
      tooltip: tooltip,
      width: width,
    );
  }

  /// Secondary variant constructor
  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    IconData? trailingIcon,
    String? tooltip,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      trailingIcon: trailingIcon,
      tooltip: tooltip,
      width: width,
    );
  }

  /// Destructive variant constructor
  factory AppButton.destructive({
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    IconData? trailingIcon,
    String? tooltip,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.destructive,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      trailingIcon: trailingIcon,
      tooltip: tooltip,
      width: width,
    );
  }

  /// Tonal variant constructor
  factory AppButton.tonal({
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    IconData? trailingIcon,
    String? tooltip,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.tonal,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      trailingIcon: trailingIcon,
      tooltip: tooltip,
      width: width,
    );
  }

  /// Text variant constructor
  factory AppButton.text({
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    String? tooltip,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.text,
      size: size,
      isLoading: isLoading,
      icon: icon,
      trailingIcon: trailingIcon,
      tooltip: tooltip,
    );
  }

  /// Ghost variant constructor
  factory AppButton.ghost({
    required String label,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    IconData? icon,
    IconData? trailingIcon,
    String? tooltip,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.ghost,
      size: size,
      isLoading: isLoading,
      icon: icon,
      trailingIcon: trailingIcon,
      tooltip: tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Widget _buildButton(BuildContext context) {
    final height = _getHeight();
    final borderRadius = _getBorderRadius();

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: _buildButtonContent(context, height, borderRadius),
      );
    }

    if (width != null) {
      return SizedBox(
        width: width,
        child: _buildButtonContent(context, height, borderRadius),
      );
    }

    return _buildButtonContent(context, height, borderRadius);
  }

  Widget _buildButtonContent(BuildContext context, double height, double borderRadius) {
    final isEnabled = onPressed != null && !isLoading;

    return Material(
      color: _getBackgroundColor(context),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: _getSplashColor(context),
        highlightColor: _getHighlightColor(context),
        child: Container(
          height: height,
          padding: _getPadding(),
          child: _buildButtonChild(context),
        ),
      ),
    );
  }

  Widget _buildButtonChild(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: AppIconSize.sm,
            height: AppIconSize.sm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor(context)),
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: _getTextStyle().copyWith(color: _getTextColor(context)),
            ),
          ],
        ],
      );
    }

    if (icon != null && trailingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppIconSize.md, color: _getIconColor(context)),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: _getTextStyle().copyWith(color: _getTextColor(context))),
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: AppIconSize.md, color: _getIconColor(context)),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppIconSize.md, color: _getIconColor(context)),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: _getTextStyle().copyWith(color: _getTextColor(context))),
        ],
      );
    }

    if (trailingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: _getTextStyle().copyWith(color: _getTextColor(context))),
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: AppIconSize.md, color: _getIconColor(context)),
        ],
      );
    }

    return Center(
      child: Text(
        label,
        style: _getTextStyle().copyWith(color: _getTextColor(context)),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return AppTouchTarget.min;
      case AppButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return AppRadius.sm;
      case AppButtonSize.medium:
        return AppRadius.button;
      case AppButtonSize.large:
        return AppRadius.lg;
    }
  }

  EdgeInsets _getPadding() {
    final horizontalPadding = icon != null || trailingIcon != null
        ? AppSpacing.md
        : AppSpacing.lg;

    return EdgeInsets.symmetric(horizontal: horizontalPadding);
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.primary;
      case AppButtonVariant.secondary:
        return Colors.transparent;
      case AppButtonVariant.destructive:
        return colorScheme.secondary;
      case AppButtonVariant.tonal:
        return colorScheme.primaryContainer;
      case AppButtonVariant.text:
        return Colors.transparent;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getSplashColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.primaryContainer;
      case AppButtonVariant.secondary:
        return colorScheme.primary.withValues(alpha: 0.1);
      case AppButtonVariant.destructive:
        return colorScheme.secondary.withValues(alpha: 0.2);
      case AppButtonVariant.tonal:
        return colorScheme.primary.withValues(alpha: 0.1);
      case AppButtonVariant.text:
        return colorScheme.primary.withValues(alpha: 0.1);
      case AppButtonVariant.ghost:
        return colorScheme.primary.withValues(alpha: 0.1);
    }
  }

  Color _getHighlightColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.primaryContainer;
      case AppButtonVariant.secondary:
        return colorScheme.primary.withValues(alpha: 0.05);
      case AppButtonVariant.destructive:
        return colorScheme.secondary.withValues(alpha: 0.1);
      case AppButtonVariant.tonal:
        return colorScheme.primary.withValues(alpha: 0.05);
      case AppButtonVariant.text:
        return colorScheme.primary.withValues(alpha: 0.05);
      case AppButtonVariant.ghost:
        return colorScheme.primary.withValues(alpha: 0.05);
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isLoading;

    if (!isEnabled) {
      return colorScheme.onSurface.withValues(alpha: 0.38);
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return colorScheme.primary;
      case AppButtonVariant.destructive:
        return colorScheme.onSecondary;
      case AppButtonVariant.tonal:
        return colorScheme.onPrimaryContainer;
      case AppButtonVariant.text:
        return colorScheme.primary;
      case AppButtonVariant.ghost:
        return colorScheme.primary;
    }
  }

  Color _getLoadingColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return colorScheme.primary;
      case AppButtonVariant.destructive:
        return colorScheme.onSecondary;
      case AppButtonVariant.tonal:
        return colorScheme.onPrimaryContainer;
      case AppButtonVariant.text:
        return colorScheme.primary;
      case AppButtonVariant.ghost:
        return colorScheme.primary;
    }
  }

  Color _getIconColor(BuildContext context) {
    return _getTextColor(context);
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.labelMedium;
      case AppButtonSize.medium:
        return AppTextStyles.labelLarge;
      case AppButtonSize.large:
        return AppTextStyles.bodyLargeSemiBold;
    }
  }
}

/// Extension to easily create buttons with common configurations
extension AppButtonExtensions on AppButton {
  /// Create a small primary button
  static AppButton smallPrimary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton.primary(
      label: label,
      onPressed: onPressed,
      size: AppButtonSize.small,
      isLoading: isLoading,
      icon: icon,
    );
  }

  /// Create a large primary button
  static AppButton largePrimary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton.primary(
      label: label,
      onPressed: onPressed,
      size: AppButtonSize.large,
      isLoading: isLoading,
      icon: icon,
    );
  }
}
