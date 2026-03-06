import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Card variants for different use cases
enum AppCardVariant {
  /// Default card - white background with border
  defaultCard,

  /// Elevated card - with shadow
  elevated,

  /// Outlined card - only border, no fill
  outlined,

  /// Colored card - with primary container background
  colored,

  /// Gradient card - with gradient background
  gradient,
}

/// WiseSpends AppCard Component
///
/// A standardized card component with consistent styling across the app.
///
/// Features:
/// - Multiple variants (default, elevated, outlined, colored, gradient)
/// - Consistent padding and border radius
/// - Optional onTap callback
/// - Optional leading widget (icon/avatar)
/// - Optional trailing widget
/// - Title and subtitle support
/// - Custom content support
///
/// Usage:
/// ```dart
/// // Basic card
/// AppCard(
///   child: Text('Content'),
/// )
///
/// // Elevated card
/// AppCard.elevated(
///   child: Text('Content'),
/// )
///
/// // Card with onTap
/// AppCard(
///   onTap: () {},
///   title: 'Title',
///   subtitle: 'Subtitle',
/// )
///
/// // Card with leading and trailing
/// AppCard(
///   leading: Icon(Icons.home),
///   title: 'Home',
///   trailing: Icon(Icons.chevron_right),
///   onTap: () {},
/// )
///
/// // Colored card
/// AppCard.colored(
///   child: Text('Content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final double? elevation;
  final BorderSide? side;
  final bool enabled;
  final String? semanticLabel;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.defaultCard,
    this.onTap,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.elevation,
    this.side,
    this.enabled = true,
    this.semanticLabel,
  });

  /// Elevated variant constructor
  factory AppCard.elevated({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Widget? leading,
    Widget? trailing,
    String? title,
    String? subtitle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    double? elevation,
    bool enabled = true,
    String? semanticLabel,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: leading,
      trailing: trailing,
      title: title,
      subtitle: subtitle,
      padding: padding,
      margin: margin,
      color: color,
      borderRadius: borderRadius,
      elevation: elevation,
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Outlined variant constructor
  factory AppCard.outlined({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Widget? leading,
    Widget? trailing,
    String? title,
    String? subtitle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    BorderSide? side,
    bool enabled = true,
    String? semanticLabel,
  }) {
    return AppCard(
      variant: AppCardVariant.outlined,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: leading,
      trailing: trailing,
      title: title,
      subtitle: subtitle,
      padding: padding,
      margin: margin,
      color: color,
      borderRadius: borderRadius,
      side: side,
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Colored variant constructor
  factory AppCard.colored({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Widget? leading,
    Widget? trailing,
    String? title,
    String? subtitle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    bool enabled = true,
    String? semanticLabel,
  }) {
    return AppCard(
      variant: AppCardVariant.colored,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: leading,
      trailing: trailing,
      title: title,
      subtitle: subtitle,
      padding: padding,
      margin: margin,
      color: color,
      borderRadius: borderRadius,
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Gradient variant constructor
  factory AppCard.gradient({
    required Widget child,
    required Gradient gradient,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Widget? leading,
    Widget? trailing,
    String? title,
    String? subtitle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    bool enabled = true,
    String? semanticLabel,
  }) {
    return AppCard(
      variant: AppCardVariant.gradient,
      gradient: gradient,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: leading,
      trailing: trailing,
      title: title,
      subtitle: subtitle,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }

  Widget _buildCard(BuildContext context) {
    final container = Container(
      decoration: _buildDecoration(),
      child: _buildContent(),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: container);
    }

    return container;
  }

  Widget _buildContent() {
    // If title/subtitle are provided, use ListTile-style layout
    if (title != null || leading != null || trailing != null) {
      return InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.lg),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: AppTextStyles.bodySmall),
                    ],
                    if (title == null && subtitle == null) child,
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
        ),
      );
    }

    // Otherwise, use simple InkWell with child
    if (onTap != null || onLongPress != null) {
      return InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }

  Decoration _buildDecoration() {
    Color backgroundColor;
    double elevation;
    Border? border;

    switch (variant) {
      case AppCardVariant.defaultCard:
        backgroundColor = color ?? AppColors.background;
        elevation = 0;
        border = side != null
            ? Border.fromBorderSide(side!)
            : Border.all(color: AppColors.divider);
        break;
      case AppCardVariant.elevated:
        backgroundColor = color ?? AppColors.background;
        elevation = this.elevation ?? AppElevation.sm;
        border = side != null ? Border.fromBorderSide(side!) : null;
        break;
      case AppCardVariant.outlined:
        backgroundColor = Colors.transparent;
        elevation = 0;
        border = side != null
            ? Border.fromBorderSide(side!)
            : Border.all(color: AppColors.divider);
        break;
      case AppCardVariant.colored:
        backgroundColor = color ?? AppColors.primaryContainer;
        elevation = 0;
        border = null;
        break;
      case AppCardVariant.gradient:
        backgroundColor = Colors.transparent;
        elevation = 0;
        border = null;
        break;
    }

    if (variant == AppCardVariant.gradient && gradient != null) {
      return BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
      );
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
      border: border,
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: elevation / 20),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation / 2),
              ),
            ]
          : null,
    );
  }
}

/// Compact card for list items
class AppCardListItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const AppCardListItem({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Stat card for displaying metrics
class AppStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final Color? color;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return AppCard.elevated(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppTouchTarget.min,
            height: AppTouchTarget.min,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: cardColor, size: AppIconSize.lg),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.amountMedium),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: trend!.startsWith('+')
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trend!.startsWith('+')
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: AppIconSize.xs,
                    color: trend!.startsWith('+')
                        ? AppColors.success
                        : AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    trend!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: trend!.startsWith('+')
                          ? AppColors.success
                          : AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
