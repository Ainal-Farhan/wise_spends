import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_event.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_state.dart';

/// Horizontal scrollable row of filter chips for the task list.
/// Reads and dispatches to [CommitmentTaskBloc] directly.
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({super.key});

  static const _filters = [
    _FilterOption('Pending', Icons.schedule, 'pending'),
    _FilterOption('Completed', Icons.check_circle, 'completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitmentTaskBloc, CommitmentTaskState>(
      builder: (context, state) {
        // Get pending task count from state (always available, even on completed filter)
        final pendingCount = state is CommitmentTaskLoaded 
            ? state.pendingCount 
            : 0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters
                  .expand(
                    (f) => [
                      _TaskFilterChip(
                        option: f,
                        pendingCount: pendingCount,
                      ),
                      if (f != _filters.last) const SizedBox(width: 8),
                    ],
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _FilterOption {
  final String label;
  final IconData icon;
  final String value;

  const _FilterOption(this.label, this.icon, this.value);
}

class _TaskFilterChip extends StatelessWidget {
  final _FilterOption option;
  final int pendingCount;

  const _TaskFilterChip({
    required this.option,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitmentTaskBloc, CommitmentTaskState>(
      builder: (context, state) {
        final filterStatus = state is CommitmentTaskLoaded
            ? state.filterStatus
            : 'pending';
        final isSelected = filterStatus == option.value;
        
        // Show badge count only for Pending filter
        final showBadge = option.value == 'pending' && pendingCount > 0;

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                option.icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(option.label),
              if (showBadge) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
          selected: isSelected,
          onSelected: (_) => context.read<CommitmentTaskBloc>().add(
            FilterCommitmentTasksEvent(option.value),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          showCheckmark: false,
        );
      },
    );
  }
}
