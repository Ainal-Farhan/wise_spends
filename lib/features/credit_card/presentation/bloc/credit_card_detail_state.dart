import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'credit_card_detail_event.dart';

abstract class CreditCardDetailState extends Equatable {
  const CreditCardDetailState();

  @override
  List<Object?> get props => [];
}

class CreditCardDetailLoading extends CreditCardDetailState {}

/// Each charge in [charges] has its original amount stored in the DB.
/// [chargeUnpaidAmounts] maps chargeId → remaining unpaid amount so the UI
/// can show "RM X remaining" without re-computing on every build.
///
/// [paymentAllocations] maps paymentId → list of (chargeId, description, allocatedAmount)
/// so the payment history can show a breakdown per payment.
class CreditCardDetailLoaded extends CreditCardDetailState {
  final CrdCardCreditCard card;

  /// Charges filtered by [period] (for display only).
  final List<CrdCardCharge> charges;

  /// ALL charges — needed for payment sheet to show every unpaid charge
  /// regardless of the display period filter.
  final List<CrdCardCharge> allCharges;

  /// Payments filtered by [period] (for display only).
  final List<CrdCardPayment> payments;

  final double totalDebt;
  final ChargePeriod period;

  /// chargeId → unpaid amount remaining on that charge (computed from allCharges)
  final Map<String, double> chargeUnpaidAmounts;

  /// paymentId → list of charge allocation rows
  final Map<String, List<PaymentAllocationDetail>> paymentAllocations;

  const CreditCardDetailLoaded({
    required this.card,
    required this.charges,
    required this.allCharges,
    required this.payments,
    required this.totalDebt,
    required this.period,
    required this.chargeUnpaidAmounts,
    required this.paymentAllocations,
  });

  @override
  List<Object?> get props => [
    card,
    charges,
    allCharges,
    payments,
    totalDebt,
    period,
    chargeUnpaidAmounts,
    paymentAllocations,
  ];

  CreditCardDetailLoaded copyWith({ChargePeriod? period}) {
    return CreditCardDetailLoaded(
      card: card,
      charges: charges,
      allCharges: allCharges,
      payments: payments,
      chargeUnpaidAmounts: chargeUnpaidAmounts,
      paymentAllocations: paymentAllocations,
      totalDebt: totalDebt,
      period: period ?? this.period,
    );
  }
}

/// A single row linking a payment to a charge with the allocated amount.
class PaymentAllocationDetail {
  final String chargeId;
  final String chargeDescription;
  final double allocatedAmount;

  const PaymentAllocationDetail({
    required this.chargeId,
    required this.chargeDescription,
    required this.allocatedAmount,
  });
}

class CreditCardDetailError extends CreditCardDetailState {
  final String message;

  const CreditCardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
