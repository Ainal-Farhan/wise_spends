import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/saving_transaction/input_fields/current_amount_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/saving_transaction/input_fields/save_button_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/saving_transaction/input_fields/saving_title_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/saving_transaction/input_fields/transaction_amount_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/saving_transaction/input_fields/transaction_type_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/save_saving_transaction_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/components/form_field_spacing_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/ui/snack_bar/message.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/saving_transaction_form_vo.dart';

// ignore: must_be_immutable
class SavingTransactionFormWidget extends StatelessWidget {
  final SavingTransactionFormVO _savingTransactionFormVO;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _transactionAmountController =
      TextEditingController();

  String _typeOfTransaction = '';

  SavingTransactionFormWidget({Key? key, required SvngSaving saving})
      : _savingTransactionFormVO =
            SavingTransactionFormVO.fromTableData(saving),
        super(key: key);

  void setSelectedTypeOfTransaction(String value) {
    _typeOfTransaction = value;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _onSave() async {
      if (_formKey.currentState!.validate()) {
        _savingTransactionFormVO.transactionAmount =
            double.parse(_transactionAmountController.text);
        _savingTransactionFormVO.typeOfTransaction = _typeOfTransaction;
        SavingsBloc().add(SaveSavingTransactionEvent(
            savingTransactionFormVO: _savingTransactionFormVO));
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
              SavingTitleWidget(
                  title: _savingTransactionFormVO.saving?.name ?? '-'),
              context,
            ),
            verticalSpacing(40),
            _inputField(
              CurrentAmountWidget(
                  currentAmount:
                      _savingTransactionFormVO.saving?.currentAmount ?? .0),
              context,
            ),
            verticalSpacing(40),
            _inputField(
              TransactionTypeWidget(setValueFunc: setSelectedTypeOfTransaction),
              context,
            ),
            verticalSpacing(40),
            _inputField(
              TransactionAmountWidget(controller: _transactionAmountController),
              context,
            ),
            verticalSpacing(40),
            SaveButtonWidget(onTap: _onSave),
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
