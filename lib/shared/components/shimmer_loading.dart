import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

// ---------------------------------------------------------------------------
// Private helper — avoids repeating the same Container+BoxDecoration pattern
// throughout every shimmer widget.
// ---------------------------------------------------------------------------
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(AppRadius.xs)),
        shape: shape,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single-item shimmers
// ---------------------------------------------------------------------------

/// Shimmer placeholder matching the shape of a real transaction card.
class ShimmerTransactionItem extends StatelessWidget {
  const ShimmerTransactionItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading transaction',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              // Icon placeholder
              _ShimmerBox(
                width: AppTouchTarget.min,
                height: AppTouchTarget.min,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ShimmerBox(width: 120, height: 16),
                    const SizedBox(height: AppSpacing.xs),
                    const _ShimmerBox(width: 80, height: 12),
                  ],
                ),
              ),

              // Amount
              const _ShimmerBox(width: 60, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder matching the shape of a notification list item.
class ShimmerNotificationItem extends StatelessWidget {
  const ShimmerNotificationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading notification',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / icon
              const _ShimmerBox(width: 40, height: 40, shape: BoxShape.circle),
              const SizedBox(width: AppSpacing.md),

              // Body text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: AppSpacing.xs),
                    const _ShimmerBox(width: 160, height: 12),
                    const SizedBox(height: AppSpacing.sm),
                    const _ShimmerBox(width: 80, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder matching the shape of a budget card.
class ShimmerBudgetCard extends StatelessWidget {
  const ShimmerBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading budget',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBox(
                    width: AppTouchTarget.min,
                    height: AppTouchTarget.min,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(width: 100, height: 14),
                        SizedBox(height: AppSpacing.xs),
                        _ShimmerBox(width: 60, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress bar
              const _ShimmerBox(width: double.infinity, height: 8),
              const SizedBox(height: AppSpacing.xs),
              const _ShimmerBox(width: 80, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a balance / stat card.
///
/// Set [isHero] to `true` for the large hero card on the dashboard.
class ShimmerBalanceCard extends StatelessWidget {
  final bool isHero;

  const ShimmerBalanceCard({super.key, this.isHero = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading balance',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ShimmerBox(width: 100, height: 14),
              const SizedBox(height: AppSpacing.sm),
              _ShimmerBox(width: isHero ? 200 : 150, height: isHero ? 36 : 24),
              const SizedBox(height: AppSpacing.sm),
              const _ShimmerBox(width: 120, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a user profile card (e.g. settings / account page).
class ShimmerProfileCard extends StatelessWidget {
  const ShimmerProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading profile',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              // Avatar
              const _ShimmerBox(width: 56, height: 56, shape: BoxShape.circle),
              const SizedBox(width: AppSpacing.lg),

              // Name + email
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 130, height: 16),
                    SizedBox(height: AppSpacing.xs),
                    _ShimmerBox(width: 180, height: 13),
                  ],
                ),
              ),

              // Edit icon placeholder
              _ShimmerBox(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for an inline summary row
/// (e.g. "Total spent · 3 transactions").
class ShimmerSummaryRow extends StatelessWidget {
  const ShimmerSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading summary',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ShimmerBox(width: 100, height: 14),
            _ShimmerBox(width: 60, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a chart area.
class ShimmerChart extends StatelessWidget {
  final double height;

  const ShimmerChart({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading chart',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
        ),
      ),
    );
  }
}

/// Generic shimmer card — use when none of the typed variants fit.
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      excludeSemantics: true,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.border,
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List / grid shimmers
// ---------------------------------------------------------------------------

/// Vertical list of [ShimmerTransactionItem]s.
class ShimmerTransactionList extends StatelessWidget {
  final int itemCount;

  const ShimmerTransactionList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const ShimmerTransactionItem(),
    );
  }
}

/// Vertical list of [ShimmerNotificationItem]s.
class ShimmerNotificationList extends StatelessWidget {
  final int itemCount;

  const ShimmerNotificationList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const ShimmerNotificationItem(),
    );
  }
}

/// Grouped transaction list with date-header shimmers.
class ShimmerGroupedList extends StatelessWidget {
  final int groupCount;
  final int itemsPerGroup;

  const ShimmerGroupedList({
    super.key,
    this.groupCount = 3,
    this.itemsPerGroup = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: groupCount,
      itemBuilder: (_, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ShimmerBox(width: 100, height: 16),
              ),
              const SizedBox(height: AppSpacing.xs),
              ShimmerTransactionList(itemCount: itemsPerGroup),
            ],
          ),
        );
      },
    );
  }
}

/// Category grid shimmer.
class ShimmerCategoryGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerCategoryGrid({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.border,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85,
        ),
        itemCount: itemCount,
        itemBuilder: (_, _) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ShimmerBox(width: 40, height: 40, shape: BoxShape.circle),
                SizedBox(height: AppSpacing.sm),
                _ShimmerBox(width: 50, height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composed / page-level shimmers
// ---------------------------------------------------------------------------

/// Two stat cards side by side.
class ShimmerStatCards extends StatelessWidget {
  const ShimmerStatCards({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: ShimmerCard(
            height: 120,
            padding: EdgeInsets.all(AppSpacing.lg),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: ShimmerCard(
            height: 120,
            padding: EdgeInsets.all(AppSpacing.lg),
          ),
        ),
      ],
    );
  }
}

/// Full dashboard loading skeleton.
class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero balance
          const ShimmerBalanceCard(isHero: true),
          const SizedBox(height: AppSpacing.md),

          // Income / expense cards
          const Row(
            children: [
              Expanded(child: ShimmerBalanceCard()),
              SizedBox(width: AppSpacing.md),
              Expanded(child: ShimmerBalanceCard()),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Section heading
          const _ShimmerBox(width: 150, height: 20),
          const SizedBox(height: AppSpacing.md),

          // Recent transactions
          const ShimmerTransactionList(itemCount: 5),
        ],
      ),
    );
  }
}

/// Full budget page loading skeleton.
class ShimmerBudgetPage extends StatelessWidget {
  final int cardCount;

  const ShimmerBudgetPage({super.key, this.cardCount = 4});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row at the top
          const ShimmerSummaryRow(),
          const SizedBox(height: AppSpacing.lg),

          // Chart placeholder
          const ShimmerChart(height: 180),
          const SizedBox(height: AppSpacing.xxl),

          // Section heading
          const _ShimmerBox(width: 120, height: 18),
          const SizedBox(height: AppSpacing.md),

          // Budget cards
          for (int i = 0; i < cardCount; i++) const ShimmerBudgetCard(),
        ],
      ),
    );
  }
}

/// Full analytics / reports page loading skeleton.
class ShimmerAnalyticsPage extends StatelessWidget {
  const ShimmerAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards row
          const ShimmerStatCards(),
          const SizedBox(height: AppSpacing.xxl),

          // Large chart
          const ShimmerChart(height: 220),
          const SizedBox(height: AppSpacing.xxl),

          // Section heading
          const _ShimmerBox(width: 140, height: 18),
          const SizedBox(height: AppSpacing.md),

          // Category grid
          const ShimmerCategoryGrid(itemCount: 8),
        ],
      ),
    );
  }
}

/// Wraps any arbitrary [child] widget in the shared shimmer colour effect.
///
/// Useful when you need a one-off shimmer that doesn't match an existing
/// typed variant. Prefer the typed variants above where possible.
class ShimmerFullPage extends StatelessWidget {
  final Widget child;

  const ShimmerFullPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.border,
      child: child,
    );
  }
}
