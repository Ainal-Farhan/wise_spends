import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class EditMoneyStoragePage extends StatefulWidget {
  static const String routeName = AppRouter.editMoneyStoragePageRoute;
  final String selectedMoneyStorageId;

  const EditMoneyStoragePage({
    Key? key,
    required this.selectedMoneyStorageId,
  }) : super(key: key);

  @override
  State<EditMoneyStoragePage> createState() => _EditMoneyStoragePageState();
}

class _EditMoneyStoragePageState extends State<EditMoneyStoragePage> {
  final _editMoneyStorageBloc = EditMoneyStorageBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      pageRoute: EditMoneyStoragePage.routeName,
      screen: EditMoneyStorageScreen(
        editMoneyStorageBloc: _editMoneyStorageBloc,
        selectedMoneyStorageId: widget.selectedMoneyStorageId,
      ),
      bloc: _editMoneyStorageBloc,
    );
  }
}
