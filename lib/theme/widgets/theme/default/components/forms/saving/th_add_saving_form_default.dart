import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/savings/event/impl/save_new_saving_event.dart';
import 'package:wise_spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_number_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_radio_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_select_one_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/forms/saving/i_th_add_saving_form.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/vo/impl/saving/add_saving_form_vo.dart';

// ignore: must_be_immutable
class ThAddSavingFormDefault extends StatefulWidget
    implements IThAddSavingForm {
  final Function eventLoader;
  final List<DropDownValueModel> moneyStorageList;

  const ThAddSavingFormDefault({
    Key? key,
    required this.eventLoader,
    this.moneyStorageList = const [],
  }) : super(key: key);

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;

  @override
  State<ThAddSavingFormDefault> createState() => _ThAddSavingFormDefaultState();
}

class _ThAddSavingFormDefaultState extends State<ThAddSavingFormDefault> {
  final AddSavingFormVO _addSavingFormVO = AddSavingFormVO();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _savingNamecontroller = TextEditingController();
  final TextEditingController _currentAmountcontroller =
      TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final SingleValueDropDownController _moneyStorageController =
      SingleValueDropDownController();

  bool _isHasGoal = false;

  void setIsSavingsHasGoal(String value) {
    setState(() {
      _isHasGoal = value == 'Yes';
    });
  }

  List<IThWidget> _formFields = [];

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      if (_formKey.currentState!.validate()) {
        _addSavingFormVO.savingName = _savingNamecontroller.text;
        _addSavingFormVO.currentAmount =
            double.parse(_currentAmountcontroller.text);
        _addSavingFormVO.isHasGoal = _isHasGoal;
        _addSavingFormVO.goalAmount =
            _isHasGoal ? double.parse(_goalAmountController.text) : 0;

        if (_moneyStorageController.dropDownValue != null) {
          _addSavingFormVO.moneyStorageId =
              _moneyStorageController.dropDownValue!.value ?? '';
        }

        widget.eventLoader(
          savingsEvent: SaveNewSavingEvent(
            addSavingFormVO: _addSavingFormVO,
          ),
        );
      } else {
        showSnackBarMessage(context, 'Please fill every field');
      }
    }

    _formFields = [
      IThInputTextFormFields(
        label: 'Saving Name',
        controller: _savingNamecontroller,
      ),
      IThInputSelectOneFormFields(
        dropDownValues: widget.moneyStorageList,
        controller: _moneyStorageController,
      ),
      IThInputNumberFormFields(
        label: 'Initial Amount',
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
          label: 'Goal Amount',
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
