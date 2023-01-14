import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/impl/update_edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_number_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_radio_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/forms/saving/i_th_edit_saving_form.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/edit_saving_form_vo.dart';

class ThEditSavingFormDefault extends StatefulWidget
    implements IThEditSavingForm {
  final SvngSaving saving;

  const ThEditSavingFormDefault({
    Key? key,
    required this.saving,
  }) : super(key: key);

  @override
  State<ThEditSavingFormDefault> createState() =>
      _ThEditSavingFormDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThEditSavingFormDefaultState extends State<ThEditSavingFormDefault> {
  late EditSavingFormVO _editSavingFormVO;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _savingNamecontroller = TextEditingController();
  final TextEditingController _currentAmountcontroller =
      TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();

  bool _isHasGoal = false;

  void setIsSavingsHasGoal(String value) {
    setState(() {
      _isHasGoal = value == 'Yes';
    });
  }

  List<IThWidget> _formFields = [];

  @override
  Widget build(BuildContext context) {
    _editSavingFormVO = EditSavingFormVO(
      savingId: widget.saving.id,
      savingName: widget.saving.name ?? '',
      currentAmount: widget.saving.currentAmount,
      isHasGoal: widget.saving.isHasGoal,
      goalAmount: widget.saving.goal,
    );

    _savingNamecontroller.value = TextEditingValue(
      text: _editSavingFormVO.savingName,
    );
    _currentAmountcontroller.value = TextEditingValue(
      text: _editSavingFormVO.currentAmount.toStringAsFixed(2),
    );
    _goalAmountController.value = TextEditingValue(
      text: _editSavingFormVO.goalAmount.toStringAsFixed(2),
    );
    _isHasGoal = _editSavingFormVO.isHasGoal;

    Future<void> onSave() async {
      if (_formKey.currentState!.validate()) {
        _editSavingFormVO.savingName = _savingNamecontroller.text;
        _editSavingFormVO.currentAmount =
            double.parse(_currentAmountcontroller.text);
        _editSavingFormVO.isHasGoal = _isHasGoal;
        _editSavingFormVO.goalAmount =
            _isHasGoal ? double.parse(_goalAmountController.text) : 0;
        EditSavingsBloc().add(UpdateEditSavingsEvent(_editSavingFormVO));
      } else {
        showSnackBarMessage(context, 'Please fill every field');
      }
    }

    _formFields = [
      IThInputTextFormFields(
        label: 'Saving Name',
        controller: _savingNamecontroller,
      ),
      IThInputNumberFormFields(
        label: 'Current Amount (RM)',
        controller: _currentAmountcontroller,
      ),
      IThInputRadioFormFields(
        label: 'Has Goal',
        isInline: true,
        optionsList: const ["Yes", "No"],
        setValueFunc: setIsSavingsHasGoal,
        value: _isHasGoal ? 'Yes' : 'No',
      ),
    ];

    if (_isHasGoal) {
      _formFields.add(
        IThInputNumberFormFields(
          label: 'Goal Amount (RM)',
          controller: _goalAmountController,
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ..._setFormFields(context),
            IThSaveButton(onTap: onSave),
          ],
        ),
      ),
    );
  }

  List<Widget> _setFormFields(context) {
    List<Widget> fields = [];
    for (IThWidget widget in _formFields) {
      fields.add(
        _inputField(widget, context),
      );
      fields.add(
        IThVerticalSpacingFormFields(height: 20.0),
      );
    }
    return fields;
  }

  Widget _inputField(Widget widget, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          widget,
        ],
      ),
    );
  }
}
