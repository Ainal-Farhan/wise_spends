import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/savings/event/save_saving_transaction_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/constant/saving/saving_constant.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_number_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_radio_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_output_number_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_output_text_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
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
        IThOutputTextFormFields(
            title: _savingTransactionFormVO.saving?.name ?? '-'),
        context,
      ),
      IThVerticalSpacingFormFields(height: 40),
      _inputField(
        IThOutputNumberFormFields(
          value: _savingTransactionFormVO.saving?.currentAmount ?? .0,
          decimalPoint: 2,
          prefix: 'RM ',
        ),
        context,
      ),
      IThVerticalSpacingFormFields(height: 40),
    ];

    if (_savingTransactionFormVO.saving!.isHasGoal) {
      formFields.add(
        _inputField(
          IThOutputTextFormFields(
            title:
                'Goal: RM ${_savingTransactionFormVO.saving!.goal.toStringAsFixed(2)}',
          ),
          context,
        ),
      );
    }

    formFields.addAll([
      _inputField(
        IThInputRadioFormFields(
          label: 'Type',
          setValueFunc: setSelectedTypeOfTransaction,
          optionsList: SavingConstant.savingTransactionList,
          isInline: true,
        ),
        context,
      ),
      IThVerticalSpacingFormFields(height: 40),
      _inputField(
        IThInputNumberFormFields(
          label: 'Transaction Amount',
          controller: _transactionAmountController,
        ),
        context,
      ),
      IThVerticalSpacingFormFields(height: 40),
      IThSaveButton(onTap: onSave),
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
