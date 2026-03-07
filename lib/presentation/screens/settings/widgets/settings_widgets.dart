import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Expansion panel tile for settings sections
/// Provides collapsible/expandable sections for better organization
class SettingsExpansionPanel extends StatelessWidget {
  final String title;
  final String? description;
  final IconData leadingIcon;
  final Color? leadingBackgroundColor;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const SettingsExpansionPanel({
    super.key,
    required this.title,
    this.description,
    required this.leadingIcon,
    this.leadingBackgroundColor,
    required this.children,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              // Expansion is handled by ExpansionPanelList
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Leading icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: leadingBackgroundColor ??
                          AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: AppColors.primary,
                      size: AppIconSize.sm,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Expand/collapse indicator
                  const Icon(
                    Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Content (shown when expanded)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.md),
              bottomRight: Radius.circular(AppRadius.md),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced settings tile with modern Material 3 design
/// Supports:
/// - Leading icon with customizable background
/// - Title and subtitle
/// - Trailing widget (chevron, toggle, or custom)
/// - 'Coming Soon' badge for unimplemented features
/// - Destructive action styling
/// - Disabled state
class SettingsTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDisabled;
  final bool showComingSoon;
  final Color? leadingBackgroundColor;
  final Color? leadingIconColor;

  const SettingsTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
    this.showComingSoon = false,
    this.leadingBackgroundColor,
    this.leadingIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = isDisabled ? null : onTap;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveOnTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Leading icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: leadingBackgroundColor ??
                      (isDestructive
                          ? AppColors.secondary.withValues(alpha: 0.1)
                          : AppColors.primaryContainer),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  leadingIcon,
                  color: leadingIconColor ??
                      (isDestructive
                          ? AppColors.secondary
                          : AppColors.primary),
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDestructive
                                  ? AppColors.secondary
                                  : AppColors.textPrimary,
                              decoration: isDisabled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (showComingSoon) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _ComingSoonBadge(),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDisabled
                              ? AppColors.textHint
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Trailing widget
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textSecondary,
                    size: AppIconSize.md,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 'Coming Soon' badge widget
class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        'Coming Soon',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.tertiaryDark,
        ),
      ),
    );
  }
}

/// Settings tile with switch toggle
class SettingsToggleTile extends StatefulWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;
  final Color? leadingBackgroundColor;

  const SettingsToggleTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.leadingBackgroundColor,
  });

  @override
  State<SettingsToggleTile> createState() => _SettingsToggleTileState();
}

class _SettingsToggleTileState extends State<SettingsToggleTile> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Leading icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.leadingBackgroundColor ??
                  AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              widget.leadingIcon,
              color: AppColors.primary,
              size: AppIconSize.md,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: widget.isDisabled
                          ? AppColors.textHint
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Switch
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _isOn,
              onChanged: widget.isDisabled
                  ? null
                  : (value) {
                      setState(() => _isOn = value);
                      widget.onChanged?.call(value);
                    },
              activeThumbColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
