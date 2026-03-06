import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/impl/expense/payee_vo.dart';

/// Payee Events
abstract class PayeeEvent extends Equatable {
  const PayeeEvent();

  @override
  List<Object?> get props => [];
}

/// Load all payees
class LoadPayees extends PayeeEvent {
  const LoadPayees();
}

/// Load a single payee by ID
class LoadPayee extends PayeeEvent {
  final String payeeId;

  const LoadPayee(this.payeeId);

  @override
  List<Object?> get props => [payeeId];
}

/// Save payee (create or update)
class SavePayee extends PayeeEvent {
  final PayeeVO payee;

  const SavePayee(this.payee);

  @override
  List<Object?> get props => [payee];
}

/// Delete payee
class DeletePayee extends PayeeEvent {
  final String payeeId;

  const DeletePayee(this.payeeId);

  @override
  List<Object?> get props => [payeeId];
}
