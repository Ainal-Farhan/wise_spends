import 'dart:async';

import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/index.dart';

@immutable
abstract class LoginEvent {
  Stream<LoginState> applyAsync({LoginState currentState, LoginBloc bloc});
}
