import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';

/// Depends on the situation, please use [StatelessWidgetScreen] or [StatefulWidgetScreen] accordingly
/// For example:
/// If the bloc start with its initial state, please use [StatelessWidgetScreen]
abstract class StatelessWidgetScreen<T extends IBloc<T>>
    extends StatelessWidget {
  final T bloc;

  const StatelessWidgetScreen({
    required this.bloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, IState<dynamic>>(
        bloc: bloc,
        builder: (
          BuildContext context,
          IState<dynamic> currentState,
        ) =>
            currentState.build(context));
  }
}

/// Depends on the situation, please use [StatelessWidgetScreen] or [StatefulWidgetScreen] accordingly
/// For example:
/// If required initial event, please use [StatefulWidgetScreen] and include the [initialEvent] properties
abstract class StatefulWidgetScreen<T extends IBloc<T>,
    S extends ScreenState<T>> extends StatefulWidget {
  const StatefulWidgetScreen({
    required this.bloc,
    this.initialEvent,
    super.key,
  });

  final T bloc;
  final IEvent<T>? initialEvent;

  @override
  S createState();
}

/// Please extends this [ScreenState] if there is a need. 
/// For example, need to enhance [dispose] method
class ScreenState<T extends IBloc<T>> extends State<StatefulWidgetScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      widget.bloc.add(widget.initialEvent!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, IState<dynamic>>(
        bloc: widget.bloc as T,
        builder: (
          BuildContext context,
          IState<dynamic> currentState,
        ) =>
            currentState.build(context));
  }
}
