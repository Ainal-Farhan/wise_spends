// FIXED: Extracted from budget_list_screen.dart to reduce file size
import 'package:flutter/material.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_state.dart';
import 'package:wise_spends/shared/components/section_header.dart';
import 'package:wise_spends/shared/components/shimmer_loading.dart';
import 'package:wise_spends/core/config/localization_service.dart';

/// Budget header card widget - shows summary statistics
class BudgetHeaderCard extends StatelessWidget {
  final BudgetState state;

  const BudgetHeaderCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is BudgetLoading || state is BudgetInitial) {
      return const ShimmerBudgetCard();
    }

    if (state is! BudgetsLoaded) {
      return const SizedBox.shrink();
    }

    final loaded = state as BudgetsLoaded;
    final total = loaded.allBudgets.length;
    final onTrack = loaded.onTrackCount;
    final pct = total > 0 ? (onTrack / total * 100).toInt() : 0;

    return SectionHeader.card(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.tertiary,
          Theme.of(context).colorScheme.tertiary,
        ],
      ),
      icon: Icons.pie_chart_outline,
      label: 'budgets.title'.tr,
      title: '$onTrack / $total ${'budgets.on_track_label'.tr}',
      subtitle: '$pct% ${'budgets.success_rate'.tr}',
      learnMoreLabel: 'general.learn_more'.tr,
      learnLessLabel: 'general.less'.tr,
      collapsibleBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderBullet('budgets.tip_categories'.tr),
          SectionHeaderBullet('budgets.tip_period'.tr),
          SectionHeaderBullet('budgets.tip_alert'.tr),
        ],
      ),
    );
  }
}
