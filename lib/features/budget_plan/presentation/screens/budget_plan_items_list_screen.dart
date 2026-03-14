import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/data/repositories/savings_plan/impl/savings_plan_item_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/impl/savings_plan_item_tag_repository.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_item_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_items_list_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_items_list_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_items_list_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'add_edit_budget_plan_item_bottom_sheet.dart';

// ---------------------------------------------------------------------------
// Shared filter options — single source of truth used by chips + dialog
// ---------------------------------------------------------------------------

typedef _FilterOption = ({String? value, String labelKey});

const List<_FilterOption> _kPaymentFilters = [
  (value: null, labelKey: 'budget_plans.filter_all'),
  (value: 'paid', labelKey: 'budget_plans.fully_paid'),
  (value: 'deposit', labelKey: 'budget_plans.deposit_paid'),
  (value: 'outstanding', labelKey: 'budget_plans.outstanding'),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Budget Plan Items List Screen
///
/// Displays items in a horizontally scrollable table:
/// Bil | Perkara | Jumlah | Deposit | Telah Bayar | Belum Bayar
///
/// BLoC is created here and passed via [BlocProvider.value] into all
/// child bottom sheets so they share the same BLoC instance.
class BudgetPlanItemsListScreen extends StatelessWidget {
  final String planId;

  const BudgetPlanItemsListScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BudgetPlanItemsListBloc(
        SavingsPlanItemRepository(),
        SavingsPlanItemTagRepository(),
      )..add(LoadBudgetPlanItems(planId)),
      child: _BudgetPlanItemsListContent(planId: planId),
    );
  }
}

class _BudgetPlanItemsListContent extends StatefulWidget {
  final String planId;

  const _BudgetPlanItemsListContent({required this.planId});

  @override
  State<_BudgetPlanItemsListContent> createState() =>
      _BudgetPlanItemsListContentState();
}

class _BudgetPlanItemsListContentState
    extends State<_BudgetPlanItemsListContent> {
  String? _selectedPaymentStatus;
  String? _selectedTag;

  late final BudgetPlanItemsListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<BudgetPlanItemsListBloc>();
  }

  @override
  void dispose() {
    _bloc.add(const ClearBudgetPlanItems());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetPlanItemsListBloc, BudgetPlanItemsListState>(
      listenWhen: (_, current) =>
          current is BudgetPlanItemsListError ||
          current is BudgetPlanItemsListDeleteError ||
          current is BudgetPlanItemCreated ||
          current is BudgetPlanItemUpdated ||
          current is BudgetPlanItemDeleted,
      listener: (context, state) {
        if (state is BudgetPlanItemsListError) {
          _showSnackBar(context, state.message, isError: true);
        } else if (state is BudgetPlanItemsListDeleteError) {
          _showSnackBar(context, state.message, isError: true);
        } else if (state is BudgetPlanItemCreated) {
          _showSnackBar(context, 'budget_plans.item_created'.tr);
        } else if (state is BudgetPlanItemUpdated) {
          _showSnackBar(context, 'budget_plans.item_updated'.tr);
        } else if (state is BudgetPlanItemDeleted) {
          _showSnackBar(context, 'budget_plans.item_deleted'.tr);
        }
      },
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => context.read<BudgetPlanItemsListBloc>().add(
              RefreshBudgetPlanItems(widget.planId),
            ),
            child: CustomScrollView(
              slivers: [
                // Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _SummaryCard(
                      onAddItem: () => _showAddItemSheet(context),
                    ),
                  ),
                ),

                // Filter Chips + Filter Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: _FilterChips(
                      selectedPaymentStatus: _selectedPaymentStatus,
                      selectedTag: _selectedTag,
                      onPaymentStatusSelected: _onPaymentStatusSelected,
                      onTagSelected: _onTagSelected,
                    ),
                  ),
                ),

                // Table — header + rows share a single horizontal ScrollController
                // so they always scroll in sync as one unit.
                SliverToBoxAdapter(
                  child:
                      BlocBuilder<
                        BudgetPlanItemsListBloc,
                        BudgetPlanItemsListState
                      >(
                        buildWhen: (_, current) =>
                            current is BudgetPlanItemsListLoading ||
                            current is BudgetPlanItemsListLoaded ||
                            current is BudgetPlanItemsListEmpty ||
                            current is BudgetPlanItemsListError,
                        builder: (context, state) {
                          if (state is BudgetPlanItemsListLoading) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: Column(
                                children: List.generate(
                                  5,
                                  (_) => const _ItemRowShimmer(),
                                ),
                              ),
                            );
                          }
                          if (state is BudgetPlanItemsListEmpty) {
                            return _buildEmpty(context);
                          }
                          if (state is BudgetPlanItemsListError) {
                            return ErrorStateWidget(
                              message: state.message,
                              onAction: () => context
                                  .read<BudgetPlanItemsListBloc>()
                                  .add(LoadBudgetPlanItems(widget.planId)),
                            );
                          }
                          if (state is BudgetPlanItemsListLoaded) {
                            if (state.filteredItems.isEmpty) {
                              return _buildEmpty(context);
                            }
                            return _ItemCardList(
                              items: state.filteredItems,
                              onEdit: (item) =>
                                  _showEditItemSheet(context, item),
                              onDelete: (item) =>
                                  _dispatchDelete(context, item),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          ),
          // FAB rendered in Stack — avoids needing a nested Scaffold
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: FloatingActionButton(
              onPressed: () => _showAddItemSheet(context),
              elevation: 4,
              tooltip: 'budget_plans.add_item'.tr,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _onPaymentStatusSelected(String? status) {
    setState(() => _selectedPaymentStatus = status);
    context.read<BudgetPlanItemsListBloc>().add(
      FilterBudgetPlanItems(paymentStatus: status, tag: _selectedTag),
    );
  }

  void _onTagSelected(String? tag) {
    setState(() => _selectedTag = tag);
    context.read<BudgetPlanItemsListBloc>().add(
      FilterBudgetPlanItems(paymentStatus: _selectedPaymentStatus, tag: tag),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return NoBudgetPlanItemsEmptyState(
      onAddItem: () => _showAddItemSheet(context),
    );
  }

  /// Opens the add sheet with the existing BLoC passed via BlocProvider.value
  void _showAddItemSheet(BuildContext context) {
    // Calculate next Bil number from current state
    final bloc = context.read<BudgetPlanItemsListBloc>();
    final state = bloc.state;
    int? nextBilNumber;

    if (state is BudgetPlanItemsListLoaded) {
      final maxBil = state.items.fold<int>(0, (max, item) {
        final itemBil = int.tryParse(item.bil) ?? 0;
        return itemBil > max ? itemBil : max;
      });
      nextBilNumber = maxBil + 1;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AddEditBudgetPlanItemBottomSheet(
          planId: widget.planId,
          nextBilNumber: nextBilNumber,
        ),
      ),
    );
  }

  void _showEditItemSheet(BuildContext context, BudgetPlanItemEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanItemsListBloc>(),
        child: AddEditBudgetPlanItemBottomSheet(
          planId: widget.planId,
          item: item,
        ),
      ),
    );
  }

  /// Dispatches delete directly — confirmation is handled by Dismissible
  void _dispatchDelete(BuildContext context, BudgetPlanItemEntity item) {
    context.read<BudgetPlanItemsListBloc>().add(
      DeleteBudgetPlanItem(item.id, widget.planId),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    // rootScaffoldMessengerState avoids "ancestor not found" when this widget
    // is embedded inside a TabBarView under a parent Scaffold.
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// =============================================================================
// Filter Chips
// =============================================================================
class _FilterChips extends StatelessWidget {
  final String? selectedPaymentStatus;
  final String? selectedTag;
  final ValueChanged<String?> onPaymentStatusSelected;
  final ValueChanged<String?> onTagSelected;

  const _FilterChips({
    required this.selectedPaymentStatus,
    required this.selectedTag,
    required this.onPaymentStatusSelected,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter =
        selectedPaymentStatus != null || selectedTag != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _kPaymentFilters.map((f) {
                  final isSelected = selectedPaymentStatus == f.value;
                  return FilterChip(
                    label: Text(f.labelKey.tr),
                    selected: isSelected,
                    onSelected: (selected) =>
                        onPaymentStatusSelected(selected ? f.value : null),
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              BlocBuilder<BudgetPlanItemsListBloc, BudgetPlanItemsListState>(
                buildWhen: (_, current) => current is BudgetPlanItemsListLoaded,
                builder: (context, state) {
                  if (state is! BudgetPlanItemsListLoaded) {
                    return const SizedBox.shrink();
                  }

                  final allTags = state.items
                      .expand((i) => i.tags)
                      .toSet()
                      .toList();
                  if (allTags.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      SectionHeaderCompact(title: 'budget_plans.tags'.tr),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          FilterChip(
                            label: Text('budget_plans.filter_all'.tr),
                            selected: selectedTag == null,
                            onSelected: (_) => onTagSelected(null),
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                            checkmarkColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          ...allTags.map(
                            (tag) => FilterChip(
                              label: Text(tag),
                              selected: selectedTag == tag,
                              onSelected: (selected) =>
                                  onTagSelected(selected ? tag : null),
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              checkmarkColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
              tooltip: 'general.filter'.tr,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (hasActiveFilter)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? localStatus = selectedPaymentStatus;

    showCustomContentDialog(
      context: context,
      title: 'general.filter'.tr,
      content: StatefulBuilder(
        builder: (_, setLocalState) => RadioGroup<String?>(
          groupValue: localStatus,
          onChanged: (v) => setLocalState(() => localStatus = v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'budget_plans.payment_status'.tr,
                style: AppTextStyles.bodySemiBold,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._kPaymentFilters.map(
                (f) => RadioListTile<String?>(
                  title: Text(f.labelKey.tr),
                  value: f.value,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        DialogAction(
          text: 'general.clear'.tr,
          onPressed: () {
            onPaymentStatusSelected(null);
            onTagSelected(null);
            Navigator.pop(context);
          },
        ),
        DialogAction(
          text: 'general.apply'.tr,
          isPrimary: true,
          onPressed: () {
            onPaymentStatusSelected(localStatus);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

// =============================================================================
// Summary Card
// =============================================================================

class _SummaryCard extends StatelessWidget {
  final VoidCallback onAddItem;

  const _SummaryCard({required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetPlanItemsListBloc, BudgetPlanItemsListState>(
      builder: (context, state) {
        if (state is BudgetPlanItemsListLoading) {
          return const ShimmerCard(height: 120);
        }

        if (state is BudgetPlanItemsListLoaded) {
          final summary = state.summary;
          return SectionHeader.card(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary,
              ],
            ),
            icon: Icons.format_list_bulleted,
            label: 'budget_plans.items_summary'.tr,
            title: 'Total Cost: RM ${summary.totalCost.toStringAsFixed(2)}',
            subtitle: '${summary.totalItems} ${'budget_plans.items_count'.tr}',
            collapsibleBody: _SummaryDetail(summary: summary),
            learnMoreLabel: 'general.details'.tr,
            learnLessLabel: 'general.less'.tr,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SummaryDetail extends StatelessWidget {
  final BudgetPlanItemsSummary summary;

  const _SummaryDetail({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryRow(
          label: 'budget_plans.total_deposit'.tr,
          amount: summary.totalDepositPaid,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(height: AppSpacing.xs),
        _SummaryRow(
          label: 'budget_plans.total_paid'.tr,
          amount: summary.totalAmountPaid,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.xs),
        _SummaryRow(
          label: 'budget_plans.total_outstanding'.tr,
          amount: summary.totalOutstanding,
          color: summary.totalOutstanding > 0
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _SummaryChip(
              label: 'budget_plans.fully_paid'.tr,
              count: summary.fullyPaidItems,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            _SummaryChip(
              label: 'budget_plans.deposit_paid'.tr,
              count: summary.depositPaidItems,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            _SummaryChip(
              label: 'budget_plans.outstanding'.tr,
              count: summary.outstandingItems,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
        AmountText(
          amount: amount,
          type: AmountType.neutral,
          showPrefix: false,
          style: AppTextStyles.bodySemiBold.copyWith(color: color),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Item Card List
// =============================================================================

class _ItemCardList extends StatelessWidget {
  final List<BudgetPlanItemEntity> items;
  final ValueChanged<BudgetPlanItemEntity> onEdit;
  final ValueChanged<BudgetPlanItemEntity> onDelete;

  const _ItemCardList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: items
            .map(
              (item) => _ItemCard(
                key: ValueKey(item.id),
                item: item,
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
              ),
            )
            .toList(),
      ),
    );
  }
}

// =============================================================================
// Item Card — Dismissible swipe-to-delete
// =============================================================================

class _ItemCard extends StatelessWidget {
  final BudgetPlanItemEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('dismiss_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDeleteDialog(
        context: context,
        title: 'budget_plans.delete_item'.tr,
        message: 'budget_plans.delete_item_msg'.trWith({'name': item.name}),
        deleteText: 'general.delete'.tr,
        cancelText: 'general.cancel'.tr,
      ),
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: _ItemCardContent(item: item, onEdit: onEdit, onDelete: onDelete),
    );
  }
}

// =============================================================================
// Item Card Content
// =============================================================================

class _ItemCardContent extends StatelessWidget {
  final BudgetPlanItemEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCardContent({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = item.totalCost > 0
        ? (item.totalPaid / item.totalCost).clamp(0.0, 1.0)
        : 0.0;

    final Color statusColor;
    final String statusLabel;
    if (item.isFullyPaid) {
      statusColor = Theme.of(context).colorScheme.primary;
      statusLabel = 'budget_plans.status_fully_paid'.tr;
    } else if (item.depositPaid > 0) {
      statusColor = Theme.of(context).colorScheme.tertiary;
      statusLabel = 'budget_plans.status_deposit_paid'.tr;
    } else {
      statusColor = Theme.of(context).colorScheme.secondary;
      statusLabel = 'budget_plans.status_not_paid'.tr;
    }

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // ── Main content ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bil badge
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: AppSpacing.md, top: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.bil.isEmpty ? '—' : item.bil,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  // Name + due date + tags
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.dueDate != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  _formatDate(item.dueDate!),
                                  style: AppTextStyles.caption.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (item.tags.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              ...item.tags
                                  .take(2)
                                  .map((tag) => _TagBadge(tag: tag)),
                              if (item.tags.length > 2)
                                _TagBadge(
                                  tag: '+${item.tags.length - 2}',
                                  isOverflow: true,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Right: fixed-width column so it never overflows
                  SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Menu button — top-right
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => _showOptions(context),
                            child: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Total cost
                        AmountText(
                          amount: item.totalCost,
                          type: AmountType.neutral,
                          showPrefix: false,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 2),
                        // Outstanding / paid label
                        if (!item.isFullyPaid)
                          Text(
                            'RM ${item.outstanding.toStringAsFixed(2)} left',
                            style: AppTextStyles.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'budget_plans.status_fully_paid'.tr,
                            style: AppTextStyles.caption.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ── Paid / Deposit row ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  _AmountPill(
                    label: 'Paid',
                    amount: item.totalPaid,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (item.depositPaid > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _AmountPill(
                      label: 'Deposit',
                      amount: item.depositPaid,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text('budget_plans.edit_item'.tr),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'general.delete'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Amount Pill — small label + amount chip shown in card footer
// =============================================================================

class _AmountPill extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _AmountPill({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Tag Badge
// =============================================================================

class _TagBadge extends StatelessWidget {
  final String tag;
  final bool isOverflow;

  const _TagBadge({required this.tag, this.isOverflow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOverflow
            ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: isOverflow
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// =============================================================================
// Item Card Shimmer
// =============================================================================

class _ItemRowShimmer extends StatelessWidget {
  const _ItemRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ShimmerCard(
        height: 120,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
