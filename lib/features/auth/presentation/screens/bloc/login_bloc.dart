import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoadLoginEvent>(_onLoadLogin);
    on<UnLoginEvent>(_onUnLogin);
  }

  Future<void> _onLoadLogin(
    LoadLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(UnLoginState());
    await Future.delayed(const Duration(seconds: 1));
    emit(const InLoginState(hello: 'Hello world'));
  }

  Future<void> _onUnLogin(UnLoginEvent event, Emitter<LoginState> emit) async {
    emit(UnLoginState());
  }
}
