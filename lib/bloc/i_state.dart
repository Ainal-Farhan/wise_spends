import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class IState<T extends IState<T>> extends Equatable {
  const IState({
    required this.version,
  });

  /// notify change state without deep clone state
  final int version;

  Widget build(BuildContext context);

  /// Copy object for use in action
  /// if need use deep clone
  T getStateCopy();

  T getNewVersion();

  @override
  List<Object> get props => [version];
}
