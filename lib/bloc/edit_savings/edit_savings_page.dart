import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class EditSavingsPage extends StatefulWidget {
  static const String routeName = AppRouter.editSavingsPageRoute;
  final String savingId;

  const EditSavingsPage({
    super.key,
    required this.savingId,
  });

  @override
  State<EditSavingsPage> createState() => _EditSavingsPageState();
}

class _EditSavingsPageState extends State<EditSavingsPage> {
  final _editSavingsBloc = EditSavingsBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      screen: EditSavingsScreen(
        editSavingsBloc: _editSavingsBloc,
        savingId: widget.savingId,
      ),
      pageRoute: EditSavingsPage.routeName,
      bloc: _editSavingsBloc,
    );
  }
}
