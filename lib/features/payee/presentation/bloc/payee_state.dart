import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';

/// Payee States
abstract class PayeeState extends Equatable {
  const PayeeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PayeeInitial extends PayeeState {
  const PayeeInitial();
}

/// Loading state
class PayeeLoading extends PayeeState {
  const PayeeLoading();
}

/// Payees loaded state
class PayeesLoaded extends PayeeState {
  final List<PayeeVO> payees;

  const PayeesLoaded(this.payees);

  @override
  List<Object?> get props => [payees];
}

/// Payee loaded state (single)
class PayeeLoaded extends PayeeState {
  final PayeeVO payee;

  const PayeeLoaded(this.payee);

  @override
  List<Object?> get props => [payee];
}

/// Payee saved state
class PayeeSaved extends PayeeState {
  final String message;

  const PayeeSaved(this.message);

  @override
  List<Object?> get props => [message];
}

/// Payee deleted state
class PayeeDeleted extends PayeeState {
  final String message;

  const PayeeDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class PayeeError extends PayeeState {
  final String message;

  const PayeeError(this.message);

  @override
  List<Object?> get props => [message];
}
