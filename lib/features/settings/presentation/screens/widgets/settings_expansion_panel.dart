import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// A self-contained animated expansion panel used throughout the Settings
/// screen. Each panel has a sticky header with an icon, title, and info
/// tooltip, and reveals its [children] with a smooth cross-fade.
class SettingsExpansionPanel extends StatelessWidget {
  final String title;
  final String description;
  final IconData leadingIcon;
  final Color? leadingBackgroundColor;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;

  const SettingsExpansionPanel({
    super.key,
    required this.title,
    required this.description,
    required this.leadingIcon,
    this.leadingBackgroundColor,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _PanelHeader(
            title: title,
            description: description,
            leadingIcon: leadingIcon,
            leadingBackgroundColor:
                leadingBackgroundColor ??
                Theme.of(context).colorScheme.primaryContainer,
            isExpanded: isExpanded,
            onTap: () => onExpansionChanged(!isExpanded),
          ),
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

class _PanelHeader extends StatelessWidget {
  final String title;
  final String description;
  final IconData leadingIcon;
  final Color leadingBackgroundColor;
  final bool isExpanded;
  final VoidCallback onTap;

  const _PanelHeader({
    required this.title,
    required this.description,
    required this.leadingIcon,
    required this.leadingBackgroundColor,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
                color: leadingBackgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                leadingIcon,
                color: Theme.of(context).colorScheme.primary,
                size: AppIconSize.sm,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Title + info tooltip
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(description),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Animated chevron
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
