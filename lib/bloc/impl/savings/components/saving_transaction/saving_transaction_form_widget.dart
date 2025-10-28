import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/savings/event/save_saving_transaction_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/constant/saving/saving_constant.dart';
import 'package:wise_spends/theme/widgets/components/buttons/th_save_button.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/th_input_number_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/th_input_radio_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/th_output_number_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/th_output_text_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/vo/impl/saving/saving_transaction_form_vo.dart';

// ignore: must_be_immutable
class SavingTransactionFormWidget extends StatelessWidget {
  final SavingTransactionFormVO _savingTransactionFormVO;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _transactionAmountController =
      TextEditingController();

  String _typeOfTransaction = '';

  SavingTransactionFormWidget({super.key, required SvngSaving? saving})
      : _savingTransactionFormVO =
            SavingTransactionFormVO.fromTableData(saving);

  void setSelectedTypeOfTransaction(String value) {
    _typeOfTransaction = value;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      if (_formKey.currentState!.validate()) {
        _savingTransactionFormVO.transactionAmount =
            double.parse(_transactionAmountController.text);
        _savingTransactionFormVO.typeOfTransaction = _typeOfTransaction;
        BlocProvider.of<SavingsBloc>(context).add(SaveSavingTransactionEvent(
            savingTransactionFormVO: _savingTransactionFormVO));
      } else {
        showSnackBarMessage(context, 'Please fill every field');
      }
    }

    List<Widget> formFields = <Widget>[
      _inputField(
        ThOutputTextFormFields(
            label: "Saving Name", value: _savingTransactionFormVO.saving?.name ?? '-'),
        context,
      ),
      ThVerticalSpacingFormFields(height: 40),
      _inputField(
        ThOutputNumberFormFields(
          label: "Current Amount",
          value: _savingTransactionFormVO.saving?.currentAmount ?? .0,
        ),
        context,
      ),
      ThVerticalSpacingFormFields(height: 40),
    ];

    if (_savingTransactionFormVO.saving!.isHasGoal) {
      formFields.add(
        _inputField(
          ThOutputTextFormFields(
            label: "Goal",
            value: 'RM ${_savingTransactionFormVO.saving!.goal.toStringAsFixed(2)}',
          ),
          context,
        ),
      );
    }

    formFields.addAll([
      _inputField(
        ThInputRadioFormFields(
          label: 'Type',
          options: {for (String item in SavingConstant.savingTransactionList) item: item},
          value: _typeOfTransaction,
          onChanged: (value) => setSelectedTypeOfTransaction(value!),
        ),
        context,
      ),
      ThVerticalSpacingFormFields(height: 40),
      _inputField(
        ThInputNumberFormFields(
          label: 'Transaction Amount',
          hint: 'Enter amount',
          controller: _transactionAmountController,
        ),
        context,
      ),
      ThVerticalSpacingFormFields(height: 40),
      ThSaveButton(onTap: onSave),
    ]);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: formFields,
        ),
      ),
    );
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
