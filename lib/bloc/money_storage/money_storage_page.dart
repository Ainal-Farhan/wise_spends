import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/money_storage_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class MoneyStoragePage extends StatefulWidget {
  static const String routeName = AppRouter.viewListMoneyStoragePageRoute;

  const MoneyStoragePage({super.key});

  @override
  State<MoneyStoragePage> createState() =>
      _MoneyStoragePageState();
}

class _MoneyStoragePageState extends State<MoneyStoragePage> {
  @override
  Widget build(BuildContext context) {
    final viewListMoneyStorageBloc =
        BlocProvider.of<MoneyStorageBloc>(context);
    return IThLoggedInMainTemplate(
      pageRoute: MoneyStoragePage.routeName,
      screen: MoneyStorageScreen(
        viewListMoneyStorageBloc: viewListMoneyStorageBloc,
      ),
      bloc: viewListMoneyStorageBloc,
    );
  }
}
