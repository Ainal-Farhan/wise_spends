import 'package:wise_spends/bloc/login/index.dart';

/// Initialized
class InLoginState extends LoginState {
  const InLoginState(this.hello);

  final String hello;

  @override
  String toString() => 'InLoginState $hello';

  @override
  List<Object> get props => [hello];

  @override
  String get message => hello;
}
