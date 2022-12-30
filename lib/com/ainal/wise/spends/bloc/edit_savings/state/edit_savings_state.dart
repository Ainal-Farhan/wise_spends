import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class EditSavingsState extends Equatable {
  const EditSavingsState({
    required this.version,
  });

  /// notify change state without deep clone state
  final int version;

  Widget build(BuildContext context);

  /// Copy object for use in action
  /// if need use deep clone
  EditSavingsState getStateCopy();

  EditSavingsState getNewVersion();

  @override
  List<Object> get props => [version];
}
