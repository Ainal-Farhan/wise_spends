import 'package:equatable/equatable.dart';
import 'package:wise_spends/core/constants/constant/enum/category_enum.dart';

abstract class AddCategoryFormState extends Equatable {
  const AddCategoryFormState();

  @override
  List<Object?> get props => [];
}

class AddCategoryFormInitial extends AddCategoryFormState {}

class AddCategoryFormLoading extends AddCategoryFormState {}

class AddCategoryFormReady extends AddCategoryFormState {
  final String name;
  final CategoryType type;
  final int iconCodePoint;

  const AddCategoryFormReady({
    this.name = '',
    this.type = CategoryType.expense,
    this.iconCodePoint = 0xE8B0, // Default: Icons.category
  });

  @override
  List<Object?> get props => [name, type, iconCodePoint];

  AddCategoryFormReady copyWith({
    String? name,
    CategoryType? type,
    int? iconCodePoint,
  }) {
    return AddCategoryFormReady(
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }
}

class AddCategoryFormError extends AddCategoryFormState {
  final String message;

  const AddCategoryFormError(this.message);

  @override
  List<Object> get props => [message];
}
