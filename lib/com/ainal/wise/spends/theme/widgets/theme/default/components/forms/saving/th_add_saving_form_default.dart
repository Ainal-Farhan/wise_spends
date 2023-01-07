import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/save_new_saving_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_number_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/forms/saving/i_th_add_saving_form.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/add_saving_form_vo.dart';

class ThAddSavingFormDefault extends StatelessWidget
    implements IThAddSavingForm {
  final AddSavingFormVO _addSavingFormVO = AddSavingFormVO();
  final Function _eventLoader;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _savingNamecontroller = TextEditingController();
  final TextEditingController _currentAmountcontroller =
      TextEditingController();

  ThAddSavingFormDefault({
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
              IThInputTextFormFields(
                label: 'Saving Name',
                controller: _savingNamecontroller,
              ),
              context,
            ),
            IThVerticalSpacingFormFields(height: 40.0),
            _inputField(
              IThInputNumberFormFields(
                label: 'Initial Amount',
                controller: _currentAmountcontroller,
              ),
              context,
            ),
            IThVerticalSpacingFormFields(height: 40),
            IThSaveButton(onTap: onSave),
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

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
