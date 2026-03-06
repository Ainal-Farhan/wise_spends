import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';

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

/// Initialize edit form with existing commitment
class InitializeEditCommitmentFormEvent extends AddCommitmentFormEvent {
  final CommitmentVO commitment;

  const InitializeEditCommitmentFormEvent(this.commitment);

  @override
  List<Object?> get props => [commitment];
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
