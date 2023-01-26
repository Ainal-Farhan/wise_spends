import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ViewListMoneyStorageState extends Equatable {
  const ViewListMoneyStorageState({
    required this.version,
  });

  /// notify change state without deep clone state
  final int version;

  Widget build(BuildContext context);

  /// Copy object for use in action
  /// if need use deep clone
  ViewListMoneyStorageState getStateCopy();

  ViewListMoneyStorageState getNewVersion();

  @override
  List<Object> get props => [version];
}
