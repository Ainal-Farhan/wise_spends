import 'package:wise_spends/bloc/login/index.dart';

class ErrorLoginState extends LoginState {
  const ErrorLoginState(this.errorMessage);

  final String errorMessage;

  @override
  String toString() => 'ErrorLoginState';

  @override
  List<Object> get props => [errorMessage];

  @override
  String get message => errorMessage;
}
