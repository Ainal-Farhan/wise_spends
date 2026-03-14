import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Badge status types for color coding
enum AppBadgeStatus {
  /// Success/On track - Green
  success,

  /// Warning/Slightly behind - Amber
  warning,

  /// Error/At risk - Red
  error,

  /// Info/Neutral - Blue
  info,

  /// Completed - Grey
  completed,

  /// Custom color
  custom,
}

/// Badge variants
enum AppBadgeVariant {
  /// Filled badge - solid background color
  filled,

  /// Outlined badge - border with transparent background
  outlined,

  /// Soft badge - light background with colored text
  soft,
}

/// WiseSpends AppBadge Component
///
/// A standardized badge component for displaying status indicators.
///
/// Features:
/// - Multiple status types (success, warning, error, info, completed)
/// - Multiple variants (filled, outlined, soft)
/// - Custom color support
/// - Optional icon
/// - Consistent styling
///
/// Usage:
/// ```dart
/// // Success badge
/// AppBadge(
///   label: 'On Track',
///   status: AppBadgeStatus.success,
/// )
///
/// // Warning badge
/// AppBadge(
///   label: 'At Risk',
///   status: AppBadgeStatus.warning,
/// )
///
/// // Outlined variant
/// AppBadge(
///   label: 'Active',
///   status: AppBadgeStatus.success,
///   variant: AppBadgeVariant.outlined,
/// )
///
/// // With icon
/// AppBadge(
///   label: 'Verified',
///   status: AppBadgeStatus.success,
///   icon: Icons.check_circle,
/// )
/// ```
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeStatus status;
  final AppBadgeVariant variant;
  final IconData? icon;
  final Color? customColor;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppBadge({
    super.key,
    required this.label,
    this.status = AppBadgeStatus.info,
    this.variant = AppBadgeVariant.filled,
    this.icon,
    this.customColor,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getColor(colorScheme);
    final backgroundColor = _getBackgroundColor(color);
    final textColor = _getTextColor(color);

    return Container(
      height: height ?? 24,
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: variant == AppBadgeVariant.outlined
            ? Border.all(color: color, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSize.xs, color: textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(ColorScheme colorScheme) {
    if (status == AppBadgeStatus.custom && customColor != null) {
      return customColor!;
    }

    switch (status) {
      case AppBadgeStatus.success:
        return colorScheme.primary;
      case AppBadgeStatus.warning:
        return colorScheme.tertiary;
      case AppBadgeStatus.error:
        return colorScheme.secondary;
      case AppBadgeStatus.info:
        return colorScheme.primary;
      case AppBadgeStatus.completed:
        return colorScheme.outline;
      case AppBadgeStatus.custom:
        return customColor ?? colorScheme.primary;
    }
  }

  Color _getBackgroundColor(Color color) {
    switch (variant) {
      case AppBadgeVariant.filled:
        return color;
      case AppBadgeVariant.outlined:
        return Colors.transparent;
      case AppBadgeVariant.soft:
        return color.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor(Color color) {
    switch (variant) {
      case AppBadgeVariant.filled:
        return Colors.white;
      case AppBadgeVariant.outlined:
      case AppBadgeVariant.soft:
        return color;
    }
  }
}

/// Budget health badge - specialized for budget status
class BudgetHealthBadge extends StatelessWidget {
  final String status;
  final AppBadgeVariant variant;

  const BudgetHealthBadge({
    super.key,
    required this.status,
    this.variant = AppBadgeVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final badgeStatus = _getStatusFromString(status);
    final icon = _getIconForStatus(status);

    return AppBadge(
      label: _getLabelForStatus(status),
      status: badgeStatus,
      variant: variant,
      icon: icon,
    );
  }

  AppBadgeStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'on_track':
      case 'on track':
        return AppBadgeStatus.success;
      case 'slightly_behind':
      case 'slightly behind':
        return AppBadgeStatus.warning;
      case 'at_risk':
      case 'at risk':
      case 'over_budget':
      case 'overbudget':
        return AppBadgeStatus.error;
      case 'completed':
        return AppBadgeStatus.completed;
      default:
        return AppBadgeStatus.info;
    }
  }

  String _getLabelForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'on_track':
      case 'on track':
        return 'On Track';
      case 'slightly_behind':
      case 'slightly behind':
        return 'Behind';
      case 'at_risk':
      case 'at risk':
        return 'At Risk';
      case 'over_budget':
      case 'overbudget':
        return 'Over Budget';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  IconData? _getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'on_track':
      case 'on track':
        return Icons.check_circle;
      case 'slightly_behind':
      case 'slightly behind':
        return Icons.trending_up;
      case 'at_risk':
      case 'at risk':
      case 'over_budget':
      case 'overbudget':
        return Icons.warning;
      case 'completed':
        return Icons.flag;
      default:
        return null;
    }
  }
}

/// Transaction type badge - specialized for transaction status
class TransactionTypeBadge extends StatelessWidget {
  final String type;
  final AppBadgeVariant variant;

  const TransactionTypeBadge({
    super.key,
    required this.type,
    this.variant = AppBadgeVariant.soft,
  });

  @override
  Widget build(BuildContext context) {
    final badgeStatus = _getStatusFromString(type);
    final icon = _getIconForType(type);

    return AppBadge(
      label: _getLabelForType(type),
      status: badgeStatus,
      variant: variant,
      icon: icon,
    );
  }

  AppBadgeStatus _getStatusFromString(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return AppBadgeStatus.success;
      case 'expense':
        return AppBadgeStatus.error;
      case 'transfer':
        return AppBadgeStatus.info;
      default:
        return AppBadgeStatus.info;
    }
  }

  String _getLabelForType(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return 'Income';
      case 'expense':
        return 'Expense';
      case 'transfer':
        return 'Transfer';
      default:
        return type;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return Icons.arrow_downward;
      case 'expense':
        return Icons.arrow_upward;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.receipt;
    }
  }
}
