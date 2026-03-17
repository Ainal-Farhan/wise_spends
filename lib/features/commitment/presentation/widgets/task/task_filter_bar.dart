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
    _FilterOption('All', Icons.all_inclusive, 'all'),
    _FilterOption('Pending', Icons.schedule, 'pending'),
    _FilterOption('Completed', Icons.check_circle, 'completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters
              .expand(
                (f) => [
                  _TaskFilterChip(option: f),
                  if (f != _filters.last) const SizedBox(width: 8),
                ],
              )
              .toList(),
        ),
      ),
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

  const _TaskFilterChip({required this.option});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitmentTaskBloc, CommitmentTaskState>(
      builder: (context, state) {
        final filterStatus = state is CommitmentTaskLoaded
            ? state.filterStatus
            : 'all';
        final isSelected = filterStatus == option.value;

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
