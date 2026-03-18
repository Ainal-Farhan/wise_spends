import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/saving/domain/entities/reserve_vo.dart';
import 'package:wise_spends/features/saving/domain/usecases/i_savings_reserve_manager.dart';

/// Implementation of [ISavingsReserveManager] that computes reserved amounts
/// from commitment tasks and budget plan allocations
class SavingsReserveManager implements ISavingsReserveManager {
  @override
  void dispose() {
    // No resources to dispose
  }

  @override
  Future<SavingsReserveSummary> computeReservationsForSaving(
    String savingId,
  ) async {
    final reservations = <ReserveVO>[];

    // Load reservations from commitment tasks
    final commitmentReservations = await _loadCommitmentTaskReservations(
      savingId,
    );
    reservations.addAll(commitmentReservations);

    // Load reservations from budget plan linked accounts
    final budgetPlanReservations = await _loadBudgetPlanAllocationReservations(
      savingId,
    );
    reservations.addAll(budgetPlanReservations);

    // Get current amount from saving
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();
    final saving = await savingService.watchSavingById(savingId).first;
    final currentAmount = saving?.currentAmount ?? 0.0;

    // Calculate total reserved amount (only from non-completed reservations)
    final totalReserved = reservations
        .where((r) => r.affectsTransferable)
        .fold(0.0, (sum, r) => sum + r.amount);

    return SavingsReserveSummary(
      savingId: savingId,
      reservations: reservations,
      totalReserved: totalReserved,
      currentAmount: currentAmount,
    );
  }

  @override
  Future<Map<String, SavingsReserveSummary>> computeReservationsForSavings(
    List<String> savingIds,
  ) async {
    final result = <String, SavingsReserveSummary>{};

    for (final savingId in savingIds) {
      final summary = await computeReservationsForSaving(savingId);
      result[savingId] = summary;
    }

    return result;
  }

  @override
  Future<double> getTotalReservedAmount(String savingId) async {
    final summary = await computeReservationsForSaving(savingId);
    return summary.totalReserved;
  }

  @override
  Future<double> getTransferableAmount(String savingId) async {
    final summary = await computeReservationsForSaving(savingId);
    return summary.transferableAmount;
  }

  /// Load reservations from pending commitment tasks
  ///
  /// Only includes tasks where:
  /// - isDone = false (pending completion)
  /// - type is internalTransfer or thirdPartyPayment (cash doesn't affect digital accounts)
  /// - sourceSavingId matches the provided savingId
  Future<List<ReserveVO>> _loadCommitmentTaskReservations(
    String savingId,
  ) async {
    final reservations = <ReserveVO>[];

    try {
      final commitmentTaskRepo =
          SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getCommitmentTaskRepository();

      // Get all pending tasks (isDone = false)
      final tasks = await commitmentTaskRepo.watchAll(false).first;

      for (final task in tasks) {
        // Only consider tasks that deduct from this saving account
        // Cash tasks don't deduct from digital accounts
        if (task.sourceSavingId == savingId &&
            task.type != CommitmentTaskType.cash) {
          reservations.add(
            ReserveVO(
              id: task.id,
              amount: task.amount,
              description: 'Pending: ${task.name}',
              type: ReserveType.commitmentTask,
              sourceSavingId: task.sourceSavingId,
              targetSavingId: task.targetSavingId,
              isCompleted: task.isDone,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      // Log error but don't fail the entire computation
      // This ensures savings can still be used even if commitment data is unavailable
      WiseLogger().error(
        'Error loading commitment task reservations: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return reservations;
  }

  /// Load reservations from budget plan linked account allocations
  ///
  /// These represent amounts allocated from linked accounts to budget plans,
  /// which should be reserved to prevent overspending
  Future<List<ReserveVO>> _loadBudgetPlanAllocationReservations(
    String savingId,
  ) async {
    final reservations = <ReserveVO>[];

    try {
      final budgetPlanRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository();

      // Get all linked accounts for this saving
      final linkedAccounts = await budgetPlanRepo
          .watchLinkedAccountsByAccountId(savingId)
          .first;

      for (final linkedAccount in linkedAccounts) {
        // Only create reservation if there's an allocated amount
        final allocatedAmount = linkedAccount.allocatedAmount;
        if (allocatedAmount != null && allocatedAmount > 0) {
          // Get the budget plan details for description
          String planName = 'Unknown Plan';
          try {
            final plan = await budgetPlanRepo.getPlanByUuid(
              linkedAccount.planId,
            );
            planName = plan?.name ?? 'Unknown Plan';
          } catch (_) {
            // Use default name if plan cannot be loaded
          }

          reservations.add(
            ReserveVO(
              id: linkedAccount.id,
              amount: allocatedAmount,
              description: 'Allocated to: $planName',
              type: ReserveType.budgetPlanAllocation,
              planId: linkedAccount.planId,
              linkedAccountId: linkedAccount.id,
              isCompleted: false, // Budget plan allocations are always active
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      // Log error but don't fail the entire computation
      // This ensures savings can still be used even if commitment data is unavailable
      WiseLogger().error(
        'Error loading budget plan allocation reservations: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return reservations;
  }
}
