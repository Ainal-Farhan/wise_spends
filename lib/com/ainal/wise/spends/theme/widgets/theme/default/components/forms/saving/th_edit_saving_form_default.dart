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

// ignore: must_be_immutable
class ThEditSavingFormDefault extends StatefulWidget
    implements IThEditSavingForm {
  final SvngSaving saving;

  late EditSavingFormVO _editSavingFormVO;

  // fields Controller
  final TextEditingController _savingNamecontroller = TextEditingController();
  final TextEditingController _currentAmountcontroller =
      TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  bool _isHasGoal = false;

  ThEditSavingFormDefault({
    Key? key,
    required this.saving,
  }) : super(key: key) {
    _editSavingFormVO = EditSavingFormVO(
      savingId: saving.id,
      savingName: saving.name ?? '',
      currentAmount: saving.currentAmount,
      isHasGoal: saving.isHasGoal,
      goalAmount: saving.goal,
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
  }

  @override
  State<ThEditSavingFormDefault> createState() =>
      _ThEditSavingFormDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThEditSavingFormDefaultState extends State<ThEditSavingFormDefault> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void setIsSavingsHasGoal(String value) {
    setState(() {
      widget._isHasGoal = value == 'Yes';
    });
  }

  List<IThWidget> _formFields = [];

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      if (_formKey.currentState!.validate()) {
        widget._editSavingFormVO.savingName = widget._savingNamecontroller.text;
        widget._editSavingFormVO.currentAmount =
            double.parse(widget._currentAmountcontroller.text);
        widget._editSavingFormVO.isHasGoal = widget._isHasGoal;
        widget._editSavingFormVO.goalAmount = widget._isHasGoal
            ? double.parse(widget._goalAmountController.text)
            : 0;
        EditSavingsBloc().add(UpdateEditSavingsEvent(widget._editSavingFormVO));
      } else {
        showSnackBarMessage(context, 'Please fill every field');
      }
    }

    _formFields = [
      IThInputTextFormFields(
        label: 'Saving Name',
        controller: widget._savingNamecontroller,
      ),
      IThInputNumberFormFields(
        label: 'Current Amount (RM)',
        controller: widget._currentAmountcontroller,
      ),
      IThInputRadioFormFields(
        label: 'Has Goal',
        isInline: true,
        optionsList: const ["Yes", "No"],
        setValueFunc: setIsSavingsHasGoal,
        value: widget._isHasGoal ? 'Yes' : 'No',
      ),
    ];

    if (widget._isHasGoal) {
      _formFields.add(
        IThInputNumberFormFields(
          label: 'Goal Amount (RM)',
          controller: widget._goalAmountController,
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
