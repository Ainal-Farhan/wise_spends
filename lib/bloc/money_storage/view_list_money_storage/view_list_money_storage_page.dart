import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class ViewListMoneyStoragePage extends StatefulWidget {
  static const String routeName = AppRouter.viewListMoneyStoragePageRoute;

  const ViewListMoneyStoragePage({Key? key}) : super(key: key);

  @override
  State<ViewListMoneyStoragePage> createState() =>
      _ViewListMoneyStoragePageState();
}

class _ViewListMoneyStoragePageState extends State<ViewListMoneyStoragePage> {
  final _viewListMoneyStorageBloc = ViewListMoneyStorageBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      pageRoute: ViewListMoneyStoragePage.routeName,
      screen: ViewListMoneyStorageScreen(
        viewListMoneyStorageBloc: _viewListMoneyStorageBloc,
      ),
      bloc: _viewListMoneyStorageBloc,
    );
  }
}
