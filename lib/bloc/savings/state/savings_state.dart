import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SavingsState extends Equatable {
  const SavingsState(this.version);

  /// notify change state without deep clone state
  final int version;

  /// Copy object for use in action
  /// if need use deep clone
  SavingsState getStateCopy();

  SavingsState getNewVersion();

  Widget build(BuildContext context, Function load);

  @override
  List<Object> get props => [version];
}
