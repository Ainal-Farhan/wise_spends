import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';

class ErrorState<T extends IBloc<T>> extends IState<ErrorState> {
  const ErrorState(this._bloc, {super.version = 0, this.errorMessage = ''});

  final T _bloc;
  final String errorMessage;

  @override
  String toString() => 'ErrorState: ${T.runtimeType.toString()}';

  @override
  ErrorState getStateCopy() =>
      ErrorState<T>(_bloc, version: version, errorMessage: errorMessage);

  @override
  ErrorState getNewVersion() =>
      ErrorState<T>(_bloc, version: version + 1, errorMessage: errorMessage);

  @override
  List<Object> get props => [version, errorMessage];

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(errorMessage),
        Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            onPressed: () => _bloc.add(_bloc.initialState as IEvent<T>),
            child: const Text('reload'),
          ),
        ),
      ],
    ));
  }
}
