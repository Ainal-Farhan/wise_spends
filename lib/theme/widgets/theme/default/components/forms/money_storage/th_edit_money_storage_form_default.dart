import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/events/in_update_edit_money_storage_event.dart';
import 'package:wise_spends/constant/saving/money_storage_constant.dart';
import 'package:wise_spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_select_one_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/forms/money_storage/i_th_edit_money_storage_form.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';

class ThEditMoneyStorageFormDefault extends StatefulWidget
    implements IThEditMoneyStorageForm {
  ThEditMoneyStorageFormDefault({
    super.key,
    required this.editMoneyStorageFormVO,
  }) {
    {
      _shortNameController.text = editMoneyStorageFormVO.shortName ?? '';
      _longNameController.text = editMoneyStorageFormVO.longName ?? '';

      DropDownValueModel type =
          MoneyStorageConstant.moneyStorageTypeDropDownValueModelList.first;

      for (DropDownValueModel t
          in MoneyStorageConstant.moneyStorageTypeDropDownValueModelList) {
        if (t.value == editMoneyStorageFormVO.type) {
          type = t;
          break;
        }
      }

      _typeController.dropDownValue = type;
    }
  }

  final EditMoneyStorageFormVO editMoneyStorageFormVO;

  // fields Controller
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _longNameController = TextEditingController();
  final SingleValueDropDownController _typeController =
      SingleValueDropDownController();

  @override
  State<ThEditMoneyStorageFormDefault> createState() =>
      _ThEditMoneyStorageFormDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThEditMoneyStorageFormDefaultState
    extends State<ThEditMoneyStorageFormDefault> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<IThWidget> _formFields = [];

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      if (_formKey.currentState!.validate()) {
        widget.editMoneyStorageFormVO.shortName =
            widget._shortNameController.text;
        widget.editMoneyStorageFormVO.longName =
            widget._longNameController.text;
        widget.editMoneyStorageFormVO.type =
            widget._typeController.dropDownValue!.value ??
                MoneyStorageConstant
                    .moneyStorageTypeDropDownValueModelList.first.value;
        BlocProvider.of<EditMoneyStorageBloc>(context)
            .add(InUpdateEditMoneyStorageEvent(
          editMoneyStorageFormVO: widget.editMoneyStorageFormVO,
        ));
      } else {
        showSnackBarMessage(context, 'Please fill every field');
      }
    }

    _formFields.clear();
    _formFields.addAll([
      IThInputTextFormFields(
        label: 'Short Name',
        controller: widget._shortNameController,
      ),
      IThInputTextFormFields(
        label: 'Long Name',
        controller: widget._longNameController,
      ),
      IThInputSelectOneFormFields(
        dropDownValues:
            MoneyStorageConstant.moneyStorageTypeDropDownValueModelList,
        controller: widget._typeController,
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
