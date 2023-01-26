import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/events/impl/in_load_view_list_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';

class ViewListMoneyStorageScreen extends StatefulWidget {
  const ViewListMoneyStorageScreen({
    required ViewListMoneyStorageBloc viewListMoneyStorageBloc,
    Key? key,
  })  : _viewListMoneyStorageBloc = viewListMoneyStorageBloc,
        super(key: key);

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
    return BlocBuilder<ViewListMoneyStorageBloc, ViewListMoneyStorageState>(
        bloc: widget._viewListMoneyStorageBloc,
        builder: (
          BuildContext context,
          ViewListMoneyStorageState currentState,
        ) =>
            currentState.build(context));
  }
}
