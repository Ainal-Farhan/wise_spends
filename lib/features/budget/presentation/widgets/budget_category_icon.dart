// FIXED: Extracted from budget_list_screen.dart to reduce file size
import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

/// Budget category icon widget
class BudgetCategoryIcon extends StatelessWidget {
  const BudgetCategoryIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTouchTarget.min,
      height: AppTouchTarget.min,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: AppIconSize.lg,
      ),
    );
  }
}
