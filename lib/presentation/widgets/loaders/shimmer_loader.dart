import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wise_spends/shared/theme/ui_constants.dart';

/// Shimmer loading effect for transaction list
/// Shows skeleton loaders that match the shape of real content
class TransactionListShimmer extends StatelessWidget {
  final int itemCount;

  const TransactionListShimmer({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline,
      highlightColor: Theme.of(context).colorScheme.outline,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: UIConstants.spacingSmall),
        itemBuilder: (context, index) {
          return _buildTransactionShimmer(context);
        },
      ),
    );
  }

  Widget _buildTransactionShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          // Icon placeholder
          Container(
            width: UIConstants.touchTargetMin,
            height: UIConstants.touchTargetMin,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
            ),
          ),
          const SizedBox(width: UIConstants.spacingLarge),

          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: UIConstants.spacingXS),
                Container(
                  width: 80,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Amount placeholder
          Container(
            width: 60,
            height: 18,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading effect for balance cards
class BalanceCardShimmer extends StatelessWidget {
  const BalanceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline,
      highlightColor: Theme.of(context).colorScheme.outline,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingXXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 14,
              color: Colors.white,
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            Container(
              width: 180,
              height: 32,
              color: Colors.white,
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            Container(
              width: 120,
              height: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading effect for budget cards
class BudgetCardShimmer extends StatelessWidget {
  const BudgetCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline,
      highlightColor: Theme.of(context).colorScheme.outline,
      child: Container(
        margin: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: UIConstants.touchTargetMin,
                  height: UIConstants.touchTargetMin,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: UIConstants.spacingXS),
                      Container(
                        width: 60,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: UIConstants.spacingXS),
            Container(
              width: 80,
              height: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading effect for dashboard content
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance cards row
          const SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(child: BalanceCardShimmer()),
                SizedBox(width: UIConstants.spacingMedium),
                Expanded(child: BalanceCardShimmer()),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.spacingXXL),

          // Section title
          Container(
            width: 150,
            height: 20,
            color: Colors.white,
          ),
          const SizedBox(height: UIConstants.spacingMedium),

          // Transaction list shimmer
          TransactionListShimmer(itemCount: 5),
        ],
      ),
    );
  }
}

/// Generic shimmer card for any content
class GenericCardShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const GenericCardShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline,
      highlightColor: Theme.of(context).colorScheme.outline,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(UIConstants.radiusMedium),
        ),
      ),
    );
  }
}

/// Shimmer loading effect for category grid
class CategoryGridShimmer extends StatelessWidget {
  final int itemCount;

  const CategoryGridShimmer({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline,
      highlightColor: Theme.of(context).colorScheme.outline,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: UIConstants.spacingMedium,
          mainAxisSpacing: UIConstants.spacingMedium,
          childAspectRatio: 0.85,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                Container(
                  width: 50,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Shimmer loading effect for list with date headers (grouped transactions)
class GroupedTransactionListShimmer extends StatelessWidget {
  final int groupCount;
  final int itemsPerGroup;

  const GroupedTransactionListShimmer({
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
      itemBuilder: (context, groupIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header shimmer
              Container(
                width: 100,
                height: 16,
                margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: UIConstants.spacingXS),
              // Transaction items shimmer
              TransactionListShimmer(itemCount: itemsPerGroup),
            ],
          ),
        );
      },
    );
  }
}
