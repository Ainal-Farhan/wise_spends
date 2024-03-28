import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AddMoneyStorageState extends Equatable {
  const AddMoneyStorageState({
    required this.version,
  });

  /// notify change state without deep clone state
  final int version;

  Widget build(BuildContext context);

  /// Copy object for use in action
  /// if need use deep clone
  AddMoneyStorageState getStateCopy();

  AddMoneyStorageState getNewVersion();

  @override
  List<Object> get props => [version];
}
