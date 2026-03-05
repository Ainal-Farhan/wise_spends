import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// WiseSpends SectionHeader Component
///
/// A standardized section header component for consistent section titles
/// with optional "See All" action.
///
/// Features:
/// - Title with consistent styling
/// - Optional "See All" action
/// - Optional subtitle/description
/// - Optional leading widget (icon)
/// - Consistent spacing
///
/// Usage:
/// ```dart
/// // Basic section header
/// SectionHeader(
///   title: 'Recent Transactions',
/// )
///
/// // With see all action
/// SectionHeader(
///   title: 'Recent Transactions',
///   onSeeAll: () {},
/// )
///
/// // With custom see all text
/// SectionHeader(
///   title: 'Budgets',
///   seeAllText: 'View All',
///   onSeeAll: () {},
/// )
///
/// // With subtitle
/// SectionHeader(
///   title: 'Budget Plans',
///   subtitle: 'Track your savings goals',
///   onSeeAll: () {},
/// )
///
/// // With leading icon
/// SectionHeader(
///   title: 'Categories',
///   leading: Icon(Icons.category),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String? seeAllText;
  final Widget? leading;
  final Widget? trailing;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.seeAllText,
    this.leading,
    this.trailing,
    this.showDivider = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        seeAllText ?? 'See All',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.chevron_right,
                        size: AppIconSize.sm,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
        ],
      ],
    );
  }
}

/// Compact section header for cards
class SectionHeaderCompact extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllText;
  final Widget? trailing;

  const SectionHeaderCompact({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  seeAllText ?? 'See All',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: AppIconSize.xs,
                  color: AppColors.primary,
                ),
              ],
            ),
          )
        else if (trailing != null)
          trailing!
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
