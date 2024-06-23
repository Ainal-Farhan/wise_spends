import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';

abstract class IEvent<T extends Bloc<dynamic, IState<dynamic>>> {
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic> currentState, T bloc});
}
