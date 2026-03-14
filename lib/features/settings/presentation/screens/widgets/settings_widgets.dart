import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Expansion panel tile for settings sections.
///
/// This widget is **fully controlled** — the parent owns the expanded state
/// via [isExpanded] and [onExpansionChanged]. This matches the pattern used
/// in [SettingsScreen] where each panel's bool lives in the screen's State.
class SettingsExpansionPanel extends StatelessWidget {
  final String title;
  final String? description;
  final IconData leadingIcon;
  final Color? leadingBackgroundColor;
  final List<Widget> children;

  /// Whether the panel is currently expanded. Required — the parent owns this.
  final bool isExpanded;

  /// Called when the user taps the header to toggle expansion.
  final ValueChanged<bool>? onExpansionChanged;

  const SettingsExpansionPanel({
    super.key,
    required this.title,
    this.description,
    required this.leadingIcon,
    this.leadingBackgroundColor,
    required this.children,
    required this.isExpanded,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // ── Header (always visible) ──────────────────────────────────────
          InkWell(
            onTap: () => onExpansionChanged?.call(!isExpanded),
            borderRadius: isExpanded
                ? const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  )
                : BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Leading icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          leadingBackgroundColor ??
                          Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: Theme.of(context).colorScheme.primary,
                      size: AppIconSize.sm,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Title + optional description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Animated chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Collapsible content ──────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.md),
                bottomRight: Radius.circular(AppRadius.md),
              ),
              child: Column(children: children),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SettingsTile
// ────────────────────────────────────────────────────────────────────────────

/// Enhanced settings tile with Material 3 design.
///
/// Supports leading icon, title/subtitle, coming-soon badge, destructive
/// style, disabled state, and an optional custom trailing widget.
class SettingsTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDisabled;
  final bool showComingSoon;
  final bool hideTrailing;
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
    this.hideTrailing = false,
    this.leadingBackgroundColor,
    this.leadingIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Leading icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      leadingBackgroundColor ??
                      (isDestructive
                          ? Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.primaryContainer),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  leadingIcon,
                  color:
                      leadingIconColor ??
                      (isDestructive
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary),
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Title + subtitle
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
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface,
                              decoration: isDisabled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (showComingSoon) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const _ComingSoonBadge(),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDisabled
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Trailing
              if (!hideTrailing)
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: isDisabled
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: AppIconSize.md,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SettingsToggleTile
// ────────────────────────────────────────────────────────────────────────────

/// Settings tile with a [Switch] as the trailing widget.
class SettingsToggleTile extends StatefulWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;
  final Color? leadingBackgroundColor;
  final bool showComingSoon;

  const SettingsToggleTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.leadingBackgroundColor,
    this.showComingSoon = false,
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
  void didUpdateWidget(SettingsToggleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep local state in sync if the parent passes a new value.
    if (oldWidget.value != widget.value) {
      _isOn = widget.value;
    }
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
          // Leading icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  widget.leadingBackgroundColor ??
                  Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              widget.leadingIcon,
              color: Theme.of(context).colorScheme.primary,
              size: AppIconSize.md,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Title + badge + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isDisabled
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (widget.showComingSoon) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const _ComingSoonBadge(),
                    ],
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: widget.isDisabled
                          ? Theme.of(context).colorScheme.outline
                          : Theme.of(context).colorScheme.onSurfaceVariant,
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
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _ComingSoonBadge (private)
// ────────────────────────────────────────────────────────────────────────────

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
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        'settings.coming_soon'.tr,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
}
