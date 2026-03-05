import 'package:equatable/equatable.dart';

/// Add Commitment Form Events
abstract class AddCommitmentFormEvent extends Equatable {
  const AddCommitmentFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form
class InitializeAddCommitmentForm extends AddCommitmentFormEvent {
  const InitializeAddCommitmentForm();
}

/// Change commitment name
class AddCommitmentChangeName extends AddCommitmentFormEvent {
  final String name;

  const AddCommitmentChangeName(this.name);

  @override
  List<Object> get props => [name];
}

/// Change frequency
class AddCommitmentChangeFrequency extends AddCommitmentFormEvent {
  final String frequency;

  const AddCommitmentChangeFrequency(this.frequency);

  @override
  List<Object> get props => [frequency];
}

/// Clear form
class ClearAddCommitmentForm extends AddCommitmentFormEvent {}

/// Select savings account
class AddCommitmentSelectSaving extends AddCommitmentFormEvent {
  final String? savingId;

  const AddCommitmentSelectSaving(this.savingId);

  @override
  List<Object?> get props => [savingId];
}
