import 'package:flutter/material.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';

/// Pure helper functions for [CommitmentTaskType].
///
/// Kept in one place so the icon, label, and subtitle logic is never
/// duplicated across screens, cards, dialogs, and bottom sheets.

/// Returns the [IconData] that represents [type] in cards and dialogs.
IconData iconForTaskType(CommitmentTaskType? type) {
  switch (type) {
    case CommitmentTaskType.internalTransfer:
      return Icons.swap_horiz;
    case CommitmentTaskType.thirdPartyPayment:
      return Icons.send;
    case CommitmentTaskType.cash:
      return Icons.payments_outlined;
    case null:
      return Icons.schedule;
  }
}

/// Returns the human-readable label for [type].
String labelForTaskType(CommitmentTaskType? type) {
  switch (type) {
    case CommitmentTaskType.internalTransfer:
      return 'Internal Transfer';
    case CommitmentTaskType.thirdPartyPayment:
      return 'Third-Party Payment';
    case CommitmentTaskType.cash:
      return 'Cash';
    case null:
      return '—';
  }
}

/// Returns the one-line subtitle shown beneath a task name in list cards.
String subtitleForTask(CommitmentTaskVO task) {
  switch (task.type) {
    case CommitmentTaskType.internalTransfer:
      return '${task.sourceSavingName} → ${task.targetSavingName}';
    case CommitmentTaskType.thirdPartyPayment:
      return '${task.sourceSavingName} → ${task.payeeName}';
    case CommitmentTaskType.cash:
      return 'Cash payment';
    case null:
      return '';
  }
}
