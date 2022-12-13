import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/input_fields/save_saving_input_field_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/input_fields/saving_name_input_field_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/save_new_saving_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/components/form_field_spacing_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/ui/snack_bar/message.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/add_saving_form_vo.dart';

class SavingFormWidget extends StatelessWidget {
  final AddSavingFormVO _addSavingFormVO;
  final Function _eventLoader;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _savingNamecontroller = TextEditingController();

  SavingFormWidget({
    Key? key,
    required AddSavingFormVO addSavingFormVO,
    required Function eventLoader,
  })  : _addSavingFormVO = addSavingFormVO,
        _eventLoader = eventLoader,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _onSave() async {
      if (_formKey.currentState!.validate()) {
        _addSavingFormVO.savingName = _savingNamecontroller.text;
        _eventLoader(
            savingsEvent:
                SaveNewSavingEvent(addSavingFormVO: _addSavingFormVO));
      } else {
        showSnackBarMessage(context, 'Please fill every field');
      }
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            SavingNameInputFieldWidget(controller: _savingNamecontroller),
            verticalSpacing(40),
            SaveSavingInputFieldWidget(onTap: _onSave),
          ],
        ),
      ),
    );
  }
}
