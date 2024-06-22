import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class AddMoneyStoragePage extends StatefulWidget {
  static const String routeName = AppRouter.addMoneyStoragePageRoute;

  const AddMoneyStoragePage({super.key});

  @override
  State<AddMoneyStoragePage> createState() => _AddMoneyStoragePageState();
}

class _AddMoneyStoragePageState extends State<AddMoneyStoragePage> {
  final _addMoneyStorageBloc = AddMoneyStorageBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      pageRoute: AddMoneyStoragePage.routeName,
      screen: AddMoneyStorageScreen(
        addMoneyStorageBloc: _addMoneyStorageBloc,
      ),
      bloc: _addMoneyStorageBloc,
    );
  }
}
