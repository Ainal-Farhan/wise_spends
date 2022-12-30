import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/input_fields/current_amount_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/input_fields/save_saving_input_field_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/input_fields/saving_name_input_field_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/save_new_saving_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/components/form_field_spacing_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/ui/snack_bar/message.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/add_saving_form_vo.dart';

class SavingFormWidget extends StatelessWidget {
  final AddSavingFormVO _addSavingFormVO = AddSavingFormVO();
  final Function _eventLoader;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _savingNamecontroller = TextEditingController();
  final TextEditingController _currentAmountcontroller =
      TextEditingController();

  SavingFormWidget({
    Key? key,
    required Function eventLoader,
  })  : _eventLoader = eventLoader,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      if (_formKey.currentState!.validate()) {
        _addSavingFormVO.savingName = _savingNamecontroller.text;
        _addSavingFormVO.currentAmount =
            double.parse(_currentAmountcontroller.text);
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
            _inputField(
              SavingNameInputFieldWidget(controller: _savingNamecontroller),
              context,
            ),
            verticalSpacing(40),
            _inputField(
              CurrentAmountWidget(controller: _currentAmountcontroller),
              context,
            ),
            verticalSpacing(40),
            SaveSavingInputFieldWidget(onTap: onSave),
          ],
        ),
      ),
    );
  }

  Widget _inputField(Widget widget, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: widget,
    );
  }
}
