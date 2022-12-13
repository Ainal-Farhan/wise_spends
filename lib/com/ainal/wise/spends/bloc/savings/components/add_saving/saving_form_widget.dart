import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/input_fields/save_saving_input_field.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/input_fields/saving_name_input_field.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/components/form_field_spacing_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as route;

class SavingFormWidget extends StatelessWidget {
  final ISavingManager _savingManager = SavingManager();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _savingNamecontroller = TextEditingController();

  SavingFormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _onSave() async {
      if (_formKey.currentState!.validate()) {
        // save the saving
        await _savingManager.addNewSaving(name: _savingNamecontroller.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully add new Saving'),
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          route.Router.savingsPageRoute,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill every field'),
          ),
        );
      }
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            savingNameInputField(_savingNamecontroller),
            verticalSpacing(40),
            saveSavingInputField(onTap: _onSave),
          ],
        ),
      ),
    );
  }
}
