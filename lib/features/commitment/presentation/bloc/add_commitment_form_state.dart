import 'package:equatable/equatable.dart';

/// Add Commitment Form States
abstract class AddCommitmentFormState extends Equatable {
  const AddCommitmentFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AddCommitmentFormInitial extends AddCommitmentFormState {}

/// Form ready state
class AddCommitmentFormReady extends AddCommitmentFormState {
  final String name;
  final String frequency;
  final String? selectedSavingId;

  const AddCommitmentFormReady({
    this.name = '',
    this.frequency = 'monthly',
    this.selectedSavingId,
  });

  @override
  List<Object?> get props => [name, frequency, selectedSavingId];

  AddCommitmentFormReady copyWith({
    String? name,
    String? frequency,
    String? selectedSavingId,
  }) {
    return AddCommitmentFormReady(
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      selectedSavingId: selectedSavingId ?? this.selectedSavingId,
    );
  }
}
