import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/error/error_state.dart';

abstract class IBloc<B extends IBloc<B>>
    extends Bloc<IEvent<B>, IState<dynamic>> {
  final IState<dynamic> _initialState;

  IBloc(this._initialState) : super(_initialState) {
    on<IEvent<B>>((event, emit) async {
      try {
        await emit.forEach<IState<dynamic>>(
          event.applyAsync(currentState: state, bloc: this as B),
          onData: (state) => state,
          onError: (error, stackTrace) {
            developer.log('$error',
                name: B.runtimeType.toString(),
                error: error,
                stackTrace: stackTrace);
            return ErrorState<B>(this as B,
                version: 0, errorMessage: error.toString());
          },
        );
      } catch (error, stackTrace) {
        developer.log('$error',
            name: B.runtimeType.toString(),
            error: error,
            stackTrace: stackTrace);
        emit(ErrorState<B>(this as B,
            version: 0, errorMessage: error.toString()));
      }
    });
  }

  IState<dynamic> get initialState => _initialState;
}
