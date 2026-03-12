import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/category/data/constants/category_enum.dart';

abstract class AddCategoryFormEvent extends Equatable {
  const AddCategoryFormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAddCategoryForm extends AddCategoryFormEvent {
  const InitializeAddCategoryForm();
}

class AddCategoryChangeName extends AddCategoryFormEvent {
  final String name;

  const AddCategoryChangeName(this.name);

  @override
  List<Object> get props => [name];
}

class AddCategoryChangeType extends AddCategoryFormEvent {
  final CategoryType type;

  const AddCategoryChangeType(this.type);

  @override
  List<Object> get props => [type];
}

class AddCategorySelectIcon extends AddCategoryFormEvent {
  final int iconCodePoint;

  const AddCategorySelectIcon(this.iconCodePoint);

  @override
  List<Object> get props => [iconCodePoint];
}

class ClearAddCategoryForm extends AddCategoryFormEvent {
  const ClearAddCategoryForm();
}
