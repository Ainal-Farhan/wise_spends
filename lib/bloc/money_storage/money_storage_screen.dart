import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/events/in_load_view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/money_storage/money_storage_bloc.dart';

class MoneyStorageScreen extends StatefulWidget {
  const MoneyStorageScreen({
    required MoneyStorageBloc viewListMoneyStorageBloc,
    super.key,
  }) : _viewListMoneyStorageBloc = viewListMoneyStorageBloc;

  final MoneyStorageBloc _viewListMoneyStorageBloc;

  @override
  State<MoneyStorageScreen> createState() =>
      _MoneyStorageScreenState();
}

class _MoneyStorageScreenState
    extends State<MoneyStorageScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MoneyStorageBloc>(context)
        .add(InLoadViewListMoneyStorageEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoneyStorageBloc, IState<dynamic>>(
        bloc: widget._viewListMoneyStorageBloc,
        builder: (
          BuildContext context,
          IState<dynamic> currentState,
        ) {
          try {
            return currentState.build(context);
          } catch (_) {
            return currentState as Widget;
          }
        });
  }
}
