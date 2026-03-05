import 'package:equatable/equatable.dart';

/// Add Category Form States
abstract class AddCategoryFormState extends Equatable {
  const AddCategoryFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AddCategoryFormInitial extends AddCategoryFormState {}

/// Loading state
class AddCategoryFormLoading extends AddCategoryFormState {}

/// Form ready state
class AddCategoryFormReady extends AddCategoryFormState {
  final String name;
  final String type;
  final int iconCodePoint;

  const AddCategoryFormReady({
    this.name = '',
    this.type = 'expense',
    this.iconCodePoint = 0xE8B0, // Default category icon
  });

  @override
  List<Object?> get props => [name, type, iconCodePoint];

  AddCategoryFormReady copyWith({
    String? name,
    String? type,
    int? iconCodePoint,
  }) {
    return AddCategoryFormReady(
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }
}

/// Form error state
class AddCategoryFormError extends AddCategoryFormState {
  final String message;

  const AddCategoryFormError(this.message);

  @override
  List<Object> get props => [message];
}
