import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_screen.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/main_template/logged_in_main_template.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;

class EditSavingsPage extends StatefulWidget {
  static const String routeName = router.editSavingsPageRoute;

  const EditSavingsPage({Key? key}) : super(key: key);

  @override
  State<EditSavingsPage> createState() => _EditSavingsPageState();
}

class _EditSavingsPageState extends State<EditSavingsPage> {
  final _editSavingsBloc = EditSavingsBloc();

  @override
  Widget build(BuildContext context) {
    return LoggedInMainTemplate(
        screen: EditSavingsScreen(editSavingsBloc: _editSavingsBloc),
        pageRoute: router.editSavingsPageRoute,
        bloc: _editSavingsBloc);
  }
}
