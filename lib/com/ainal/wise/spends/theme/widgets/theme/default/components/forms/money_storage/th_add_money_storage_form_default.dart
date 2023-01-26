import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/events/impl/in_save_new_add_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/saving/money_storage_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_select_one_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/forms/money_storage/i_th_add_money_storage_form.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/money_storage/add_money_storage_form_vo.dart';

class ThAddMoneyStorageFormDefault extends StatefulWidget
    implements IThAddMoneyStorageForm {
  const ThAddMoneyStorageFormDefault({Key? key}) : super(key: key);

  @override
  State<ThAddMoneyStorageFormDefault> createState() =>
      _ThAddMoneyStorageFormDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThAddMoneyStorageFormDefaultState
    extends State<ThAddMoneyStorageFormDefault> {
  _ThAddMoneyStorageFormDefaultState() {
    _addMoneyStorageFormVO.type =
        MoneyStorageConstant.moneyStorageTypeDropDownValueModelList.first.value;

    _typeController.dropDownValue =
        MoneyStorageConstant.moneyStorageTypeDropDownValueModelList.first;
  }
  final AddMoneyStorageFormVO _addMoneyStorageFormVO = AddMoneyStorageFormVO();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _longNameController = TextEditingController();
  final SingleValueDropDownController _typeController =
      SingleValueDropDownController();

  final List<IThWidget> _formFields = [];

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      if (_formKey.currentState!.validate()) {
        _addMoneyStorageFormVO.shortName = _shortNameController.text;
        _addMoneyStorageFormVO.longName = _longNameController.text;
        _addMoneyStorageFormVO.type = _typeController.dropDownValue!.value ??
            MoneyStorageConstant
                .moneyStorageTypeDropDownValueModelList.first.value;
        AddMoneyStorageBloc().add(InSaveAddMoneyStorageEvent(
            addMoneyStorageFormVO: _addMoneyStorageFormVO));
      } else {
        showSnackBarMessage(context, 'Please fill every field');
      }
    }

    _formFields.clear();
    _formFields.addAll([
      IThInputTextFormFields(
        label: 'Short Name',
        controller: _shortNameController,
      ),
      IThInputTextFormFields(
        label: 'Long Name',
        controller: _longNameController,
      ),
      IThInputSelectOneFormFields(
        dropDownValues:
            MoneyStorageConstant.moneyStorageTypeDropDownValueModelList,
        controller: _typeController,
      ),
    ]);

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
