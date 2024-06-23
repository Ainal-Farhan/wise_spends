import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class InLoginState extends IState<InLoginState> {
  const InLoginState({
    required super.version,
    required this.hello,
  });

  final String hello;

  @override
  String toString() => 'InLoginState $hello';

  @override
  List<Object> get props => [hello];

  String get message => hello;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  InLoginState getNewVersion() =>
      InLoginState(version: version + 1, hello: hello);

  @override
  InLoginState getStateCopy() => InLoginState(version: version, hello: hello);
}
