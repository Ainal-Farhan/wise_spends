import 'package:equatable/equatable.dart';

/// Add Category Form Events
abstract class AddCategoryFormEvent extends Equatable {
  const AddCategoryFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form
class InitializeAddCategoryForm extends AddCategoryFormEvent {
  const InitializeAddCategoryForm();
}

/// Change category name
class AddCategoryChangeName extends AddCategoryFormEvent {
  final String name;

  const AddCategoryChangeName(this.name);

  @override
  List<Object> get props => [name];
}

/// Change category type
class AddCategoryChangeType extends AddCategoryFormEvent {
  final String type;

  const AddCategoryChangeType(this.type);

  @override
  List<Object> get props => [type];
}

/// Select icon
class AddCategorySelectIcon extends AddCategoryFormEvent {
  final int iconCodePoint;

  const AddCategorySelectIcon(this.iconCodePoint);

  @override
  List<Object> get props => [iconCodePoint];
}

/// Clear form
class ClearAddCategoryForm extends AddCategoryFormEvent {}
