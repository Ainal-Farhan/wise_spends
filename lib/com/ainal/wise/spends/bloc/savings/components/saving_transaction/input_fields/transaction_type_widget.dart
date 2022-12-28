import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/saving/saving_constant.dart';

// ignore: must_be_immutable
class TransactionTypeWidget extends StatefulWidget {
  String? value;
  Function setValueFunc;

  TransactionTypeWidget({Key? key, required this.setValueFunc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TransactionTypeWidgetState();
}

class _TransactionTypeWidgetState extends State<TransactionTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>.builder(
      groupValue: widget.value ?? '',
      onChanged: (value) => setState(() {
        widget.value = value ?? '';
        widget.setValueFunc(value);
      }),
      items: SavingConstant.savingTransactionList,
      itemBuilder: (item) => RadioButtonBuilder(
        item,
      ),
      fillColor: Colors.purple,
    );
  }
}
