part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class UnLoginState extends LoginState {
  @override
  List<Object> get props => [];
}

class InLoginState extends LoginState {
  final String hello;

  const InLoginState({required this.hello});

  @override
  List<Object> get props => [hello];
}

class LoginLoading extends LoginState {}
