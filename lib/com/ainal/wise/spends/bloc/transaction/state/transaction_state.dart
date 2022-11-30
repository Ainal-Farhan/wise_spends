import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class TransactionState extends Equatable {
  const TransactionState(this.version);

  /// notify change state without deep clone state
  final int version;

  /// Copy object for use in action
  /// if need use deep clone
  TransactionState getStateCopy();

  TransactionState getNewVersion();

  Widget build(BuildContext context, VoidCallback load);

  @override
  List<Object> get props => [version];
}
