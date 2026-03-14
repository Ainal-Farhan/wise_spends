import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  // ── Default constructor (plain section title) ─────────────────────────────

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
  }) : _isCard = false,
       // card-only fields
       gradient = null,
       icon = null,
       label = null,
       learnMoreLabel = 'Learn more',
       learnLessLabel = 'Less',
       collapsibleBody = null,
       cardBorderRadius = null,
       cardPadding = null,
       cardMargin = null;

  // ── Card constructor (gradient screen-header) ─────────────────────────────

  const SectionHeader.card({
    super.key,
    required LinearGradient this.gradient,
    required IconData this.icon,
    required String this.label,
    required this.title,
    required String this.subtitle,
    this.collapsibleBody,
    this.learnMoreLabel = 'Learn more',
    this.learnLessLabel = 'Less',
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    this.cardMargin,
  }) : _isCard = true,
       cardBorderRadius = borderRadius,
       cardPadding = padding,
       onSeeAll = null,
       seeAllText = null,
       leading = null,
       trailing = null,
       showDivider = false,
       padding = null;

  // ── Shared ────────────────────────────────────────────────────────────────

  final bool _isCard;
  final String title;

  // Plain-only
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String? seeAllText;
  final Widget? leading;
  final Widget? trailing;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  // Card-only
  final LinearGradient? gradient;
  final IconData? icon;
  final String? label;
  final Widget? collapsibleBody;
  final String learnMoreLabel;
  final String learnLessLabel;
  final BorderRadius? cardBorderRadius;
  final EdgeInsets? cardPadding;
  final EdgeInsets? cardMargin;

  @override
  Widget build(BuildContext context) {
    return _isCard
        ? _SectionHeaderCard(
            gradient: gradient!,
            icon: icon!,
            label: label!,
            title: title,
            subtitle: subtitle ?? '',
            collapsibleBody: collapsibleBody,
            learnMoreLabel: learnMoreLabel,
            learnLessLabel: learnLessLabel,
            borderRadius: cardBorderRadius,
            padding: cardPadding,
            margin: cardMargin,
          )
        : _SectionHeaderPlain(
            title: title,
            subtitle: subtitle,
            onSeeAll: onSeeAll,
            seeAllText: seeAllText,
            leading: leading,
            trailing: trailing,
            showDivider: showDivider,
            padding: padding,
          );
  }
}

// =============================================================================
// Plain variant (internal)
// =============================================================================

class _SectionHeaderPlain extends StatelessWidget {
  const _SectionHeaderPlain({
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.seeAllText,
    this.leading,
    this.trailing,
    this.showDivider = false,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String? seeAllText;
  final Widget? leading;
  final Widget? trailing;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
                    Text(title, style: AppTextStyles.h3),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: AppTextStyles.bodySmall),
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
                        seeAllText ?? 'general.see_all'.tr,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right,
                        size: AppIconSize.sm,
                        color: colorScheme.primary,
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

// =============================================================================
// Card variant (internal, stateful for collapse animation)
// =============================================================================

class _SectionHeaderCard extends StatefulWidget {
  const _SectionHeaderCard({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    this.collapsibleBody,
    required this.learnMoreLabel,
    required this.learnLessLabel,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  final LinearGradient gradient;
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final Widget? collapsibleBody;
  final String learnMoreLabel;
  final String learnLessLabel;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  @override
  State<_SectionHeaderCard> createState() => _SectionHeaderCardState();
}

class _SectionHeaderCardState extends State<_SectionHeaderCard> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? const EdgeInsets.only(bottom: 24),
      child: AppCard.gradient(
        gradient: widget.gradient,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        padding: widget.padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon + label + optional toggle pill ──────────────
            Row(
              children: [
                Icon(widget.icon, color: Colors.white70, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.collapsibleBody != null) _buildTogglePill(),
              ],
            ),
            const SizedBox(height: 16),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              widget.subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

            // ── Collapsible body ──────────────────────────────────────────
            if (widget.collapsibleBody != null)
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          widget.collapsibleBody!,
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTogglePill() {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _expanded ? widget.learnLessLabel : widget.learnMoreLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 280),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SectionHeaderCompact — unchanged from original
// =============================================================================

/// Compact section header for use inside cards.
///
/// ```dart
/// SectionHeaderCompact(title: 'Quick Actions', onSeeAll: () {})
/// ```
class SectionHeaderCompact extends StatelessWidget {
  const SectionHeaderCompact({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllText,
    this.trailing,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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
                  seeAllText ?? 'general.see_all'.tr,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: AppIconSize.xs,
                  color: colorScheme.primary,
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

// =============================================================================
// SectionHeaderBullet — for use inside SectionHeader.card collapsibleBody
// =============================================================================

/// A white bullet-point row for use inside [SectionHeader.card]'s
/// [collapsibleBody].
///
/// ```dart
/// SectionHeaderBullet('Rent or mortgage payments')
/// SectionHeaderBullet('Car insurance')
/// ```
class SectionHeaderBullet extends StatelessWidget {
  const SectionHeaderBullet(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
