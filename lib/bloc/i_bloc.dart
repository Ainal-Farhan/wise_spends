import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/constant/enum/function_enum.dart';
import 'package:wise_spends/error/error_state.dart';

abstract class IBloc<B extends IBloc<B>>
    extends Bloc<IEvent<B>, IState<dynamic>> {
  final IState<dynamic> _initialState;
  final List<IBloc<dynamic>> anotherBlocList;
  final Map<IBloc<dynamic>, StreamSubscription> anotherBlocSubscriptionMap = {};
  final Map<FunctionEnum, void Function(List<dynamic>?)> functionMap = {};

  IBloc(this._initialState, {this.anotherBlocList = const []})
      : super(_initialState) {
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

    _startSubscription();
  }

  void _startSubscription() {
    if (anotherBlocList.isEmpty) {
      return;
    }

    for (IBloc<dynamic> anotherBloc in anotherBlocList) {
      anotherBlocSubscriptionMap[anotherBloc] = anotherBloc.stream.listen(
        (state) => onAnotherBlocStateChanged(anotherBloc, state),
        onError: (error, stackTrace) {
          developer.log('$error',
              name: B.runtimeType.toString(),
              error: error,
              stackTrace: stackTrace);
        },
      );
    }
  }

  /// Derived Blocs can override this method to handle state changes from anotherBloc
  void onAnotherBlocStateChanged(
      IBloc<dynamic> anotherBloc, IState<dynamic> state) {}

  void _endAllSubscription() {
    if (anotherBlocList.isNotEmpty) {
      for (var entry in anotherBlocSubscriptionMap.entries) {
        entry.value.cancel();
      }
    }
  }

  @override
  Future<void> close() {
    _endAllSubscription();
    return super.close();
  }

  IState<dynamic> get initialState => _initialState;
}
