import 'dart:async';

import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';

abstract class IEvent<T extends IBloc<T>> {
  Stream<IState<dynamic>> applyAsync({IState<dynamic> currentState, T bloc});
}
