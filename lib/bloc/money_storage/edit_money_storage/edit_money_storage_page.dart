import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class EditMoneyStoragePage extends StatefulWidget {
  static const String routeName = AppRouter.editMoneyStoragePageRoute;
  final String selectedMoneyStorageId;

  const EditMoneyStoragePage({
    super.key,
    required this.selectedMoneyStorageId,
  });

  @override
  State<EditMoneyStoragePage> createState() => _EditMoneyStoragePageState();
}

class _EditMoneyStoragePageState extends State<EditMoneyStoragePage> {
  @override
  Widget build(BuildContext context) {
    final editMoneyStorageBloc = BlocProvider.of<EditMoneyStorageBloc>(context);
    return IThLoggedInMainTemplate(
      pageRoute: EditMoneyStoragePage.routeName,
      screen: EditMoneyStorageScreen(
        editMoneyStorageBloc: editMoneyStorageBloc,
        selectedMoneyStorageId: widget.selectedMoneyStorageId,
      ),
      bloc: editMoneyStorageBloc,
    );
  }
}
