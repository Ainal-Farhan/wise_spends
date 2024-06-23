import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/events/in_load_view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';

class ViewListMoneyStorageScreen extends StatefulWidget {
  const ViewListMoneyStorageScreen({
    required ViewListMoneyStorageBloc viewListMoneyStorageBloc,
    super.key,
  })  : _viewListMoneyStorageBloc = viewListMoneyStorageBloc;

  final ViewListMoneyStorageBloc _viewListMoneyStorageBloc;

  @override
  State<ViewListMoneyStorageScreen> createState() =>
      _ViewListMoneyStorageScreenState();
}

class _ViewListMoneyStorageScreenState
    extends State<ViewListMoneyStorageScreen> {
  @override
  void initState() {
    super.initState();
    ViewListMoneyStorageBloc().add(InLoadViewListMoneyStorageEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewListMoneyStorageBloc, IState<dynamic>>(
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
