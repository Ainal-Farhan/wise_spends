import 'package:wise_spends/core/di/i_singleton.dart';
import 'package:wise_spends/features/saving/domain/entities/reserve_vo.dart';

/// Interface for the savings reserve manager - computes reserved amounts
/// and transferable amounts for savings accounts
abstract class ISavingsReserveManager extends ISingleton {
  /// Compute all reservations for a specific savings account
  ///
  /// This includes:
  /// - Pending commitment tasks that will deduct from this saving
  /// - Budget plan linked account allocations
  Future<SavingsReserveSummary> computeReservationsForSaving(
    String savingId,
  );

  /// Compute reservations for multiple savings accounts
  Future<Map<String, SavingsReserveSummary>> computeReservationsForSavings(
    List<String> savingIds,
  );

  /// Get the total reserved amount for a savings account
  Future<double> getTotalReservedAmount(String savingId);

  /// Get the transferable amount for a savings account
  ///
  /// Transferable amount = current amount - total reserved amount
  Future<double> getTransferableAmount(String savingId);
}
