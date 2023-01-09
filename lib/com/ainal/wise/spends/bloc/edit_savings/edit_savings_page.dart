import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_screen.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class EditSavingsPage extends StatefulWidget {
  static const String routeName = AppRouter.editSavingsPageRoute;

  const EditSavingsPage({Key? key}) : super(key: key);

  @override
  State<EditSavingsPage> createState() => _EditSavingsPageState();
}

class _EditSavingsPageState extends State<EditSavingsPage> {
  final _editSavingsBloc = EditSavingsBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      screen: EditSavingsScreen(editSavingsBloc: _editSavingsBloc),
      pageRoute: EditSavingsPage.routeName,
      bloc: _editSavingsBloc,
    );
  }
}
