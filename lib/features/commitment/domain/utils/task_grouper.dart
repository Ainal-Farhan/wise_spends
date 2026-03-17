import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/commitment/domain/entities/task_group_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';

/// Utility class for grouping commitment tasks by source AND target.
///
/// Groups tasks based on task type:
/// 1. Internal Transfers: Group by source money storage + target money storage
/// 2. Third-Party Payments: Group by source money storage + payee
///
/// This makes it easier for users to complete multiple tasks with one transaction.
///
/// For example:
/// - Internal Transfer:
///   - Task 1: From Saving A (Bank X) → Saving B (Bank Y)
///   - Task 2: From Saving C (Bank X) → Saving D (Bank Y)
///   Grouped as: Bank X → Bank Y
///
/// - Third-Party Payment:
///   - Task 1: From Saving A (Bank X) → Payee John
///   - Task 2: From Saving C (Bank X) → Payee John
///   Grouped as: Bank X → John
class TaskGrouper {
  /// Groups incomplete tasks by their source AND target.
  ///
  /// - Internal transfers: grouped by source money storage + target money storage
  /// - Third-party payments: grouped by source money storage + payee
  static List<TaskGroupVO> groupTasks(
    List<CommitmentTaskVO> tasks,
    List<ListSavingVO> savings,
  ) {
    // Filter only incomplete tasks
    final incompleteTasks = tasks.where((t) => t.isDone != true).toList();

    // Create a map for quick saving lookup by ID
    final savingMap = <String, ListSavingVO>{};
    for (final saving in savings) {
      savingMap[saving.saving.id] = saving;
    }

    // Separate tasks by type for grouping
    final internalTransferGroups = <String, List<CommitmentTaskVO>>{};
    final thirdPartyPaymentGroups = <String, List<CommitmentTaskVO>>{};

    for (final task in incompleteTasks) {
      // Skip tasks without source saving
      if (task.sourceSavingId == null) {
        continue;
      }

      final sourceSaving = savingMap[task.sourceSavingId];
      if (sourceSaving == null) {
        continue;
      }

      final sourceMoneyStorageId = sourceSaving.moneyStorage?.id;

      // Group by task type
      if (task.isInternalTransfer) {
        // Skip tasks without target saving
        if (task.targetSavingId == null) {
          continue;
        }

        final targetSaving = savingMap[task.targetSavingId];
        if (targetSaving == null) {
          continue;
        }

        final targetMoneyStorageId = targetSaving.moneyStorage?.id;

        // Create group key from source and target money storage IDs
        final groupId = TaskGroupVO.createInternalTransferGroupId(
          sourceMoneyStorageId,
          targetMoneyStorageId,
        );

        internalTransferGroups.putIfAbsent(groupId, () => []).add(task);
      } else if (task.isThirdPartyPayment) {
        // Skip tasks without payee
        if (task.payeeId == null) {
          continue;
        }

        // Create group key from source money storage ID and payee ID
        final groupId = TaskGroupVO.createThirdPartyPaymentGroupId(
          sourceMoneyStorageId,
          task.payeeId,
        );

        thirdPartyPaymentGroups.putIfAbsent(groupId, () => []).add(task);
      }
      // Cash tasks are not grouped
    }

    // Convert map entries to TaskGroupVO objects
    final groups = <TaskGroupVO>[];

    // Process internal transfer groups
    for (final entry in internalTransferGroups.entries) {
      final tasksInGroup = entry.value;
      // Skip groups with only one task - they will be shown as ungrouped
      if (tasksInGroup.length < 2) continue;

      final firstTask = tasksInGroup.first;
      final sourceSaving = savingMap[firstTask.sourceSavingId];
      final targetSaving = savingMap[firstTask.targetSavingId];

      if (sourceSaving == null || targetSaving == null) continue;

      groups.add(
        TaskGroupVO(
          groupId: entry.key,
          groupType: CommitmentTaskType.internalTransfer,
          sourceMoneyStorageId: sourceSaving.moneyStorage?.id,
          sourceMoneyStorageName: sourceSaving.moneyStorage?.longName,
          targetMoneyStorageId: targetSaving.moneyStorage?.id,
          targetMoneyStorageName: targetSaving.moneyStorage?.longName,
          tasks: tasksInGroup,
        ),
      );
    }

    // Process third-party payment groups
    for (final entry in thirdPartyPaymentGroups.entries) {
      final tasksInGroup = entry.value;
      // Skip groups with only one task - they will be shown as ungrouped
      if (tasksInGroup.length < 2) continue;

      final firstTask = tasksInGroup.first;
      final sourceSaving = savingMap[firstTask.sourceSavingId];

      if (sourceSaving == null) continue;

      groups.add(
        TaskGroupVO(
          groupId: entry.key,
          groupType: CommitmentTaskType.thirdPartyPayment,
          sourceMoneyStorageId: sourceSaving.moneyStorage?.id,
          sourceMoneyStorageName: sourceSaving.moneyStorage?.longName,
          payeeId: firstTask.payeeId,
          payeeName: firstTask.payeeVO?.name,
          tasks: tasksInGroup,
        ),
      );
    }

    // Sort groups by total amount (descending)
    groups.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return groups;
  }

  /// Returns incomplete tasks that cannot be grouped or are single tasks
  /// (e.g., cash tasks, tasks without valid source/target, or unique routes)
  static List<CommitmentTaskVO> getUngroupedTasks(
    List<CommitmentTaskVO> tasks,
    List<ListSavingVO> savings,
  ) {
    final savingMap = <String, ListSavingVO>{};
    for (final saving in savings) {
      savingMap[saving.saving.id] = saving;
    }

    // Count tasks per group key to identify single-task groups
    final internalTransferCounts = <String, int>{};
    final thirdPartyPaymentCounts = <String, int>{};

    for (final task in tasks.where((t) => t.isDone != true)) {
      if (task.sourceSavingId == null) continue;
      final sourceSaving = savingMap[task.sourceSavingId];
      if (sourceSaving == null) continue;
      final sourceMoneyStorageId = sourceSaving.moneyStorage?.id;

      if (task.isInternalTransfer && task.targetSavingId != null) {
        final targetSaving = savingMap[task.targetSavingId];
        if (targetSaving != null) {
          final groupId = TaskGroupVO.createInternalTransferGroupId(
            sourceMoneyStorageId,
            targetSaving.moneyStorage?.id,
          );
          internalTransferCounts[groupId] = (internalTransferCounts[groupId] ?? 0) + 1;
        }
      } else if (task.isThirdPartyPayment && task.payeeId != null) {
        final groupId = TaskGroupVO.createThirdPartyPaymentGroupId(
          sourceMoneyStorageId,
          task.payeeId,
        );
        thirdPartyPaymentCounts[groupId] = (thirdPartyPaymentCounts[groupId] ?? 0) + 1;
      }
    }

    return tasks.where((task) {
      if (task.isDone == true) return true;
      
      // Cash tasks can't be grouped
      if (task.isCash) return true;
      
      // Tasks without source saving can't be grouped
      if (task.sourceSavingId == null) return true;
      
      // Tasks whose source saving is not found can't be grouped
      if (!savingMap.containsKey(task.sourceSavingId)) return true;

      final sourceSaving = savingMap[task.sourceSavingId]!;
      final sourceMoneyStorageId = sourceSaving.moneyStorage?.id;

      // Internal transfers without target saving can't be grouped
      if (task.isInternalTransfer) {
        if (task.targetSavingId == null) return true;
        if (!savingMap.containsKey(task.targetSavingId!)) return true;
        
        // Check if this is a single-task group
        final groupId = TaskGroupVO.createInternalTransferGroupId(
          sourceMoneyStorageId,
          savingMap[task.targetSavingId!]!.moneyStorage?.id,
        );
        if (internalTransferCounts[groupId] == 1) return true;
      }
      
      // Third-party payments without payee can't be grouped
      if (task.isThirdPartyPayment) {
        if (task.payeeId == null) return true;
        
        // Check if this is a single-task group
        final groupId = TaskGroupVO.createThirdPartyPaymentGroupId(
          sourceMoneyStorageId,
          task.payeeId,
        );
        if (thirdPartyPaymentCounts[groupId] == 1) return true;
      }
      
      return false;
    }).toList();
  }
}
