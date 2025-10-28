import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_select_one_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

class CommitmentDetailForm extends StatefulWidget {
  final CommitmentDetailVO commitmentDetailVO;
  final List<ListSavingVO> savingVOList;

  const CommitmentDetailForm({
    required this.commitmentDetailVO,
    required this.savingVOList,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CommitmentFormState();
}

class _CommitmentFormState extends State<CommitmentDetailForm> {
  _CommitmentFormState();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final SingleValueDropDownController _commitmentReferredSavingController =
      SingleValueDropDownController();

  final List<IThWidget> _formFields = [];
  final List<DropDownValueModel> savingDropDownValues = [];

  @override
  void initState() {
    if (widget.savingVOList.isNotEmpty) {
      for (ListSavingVO savingVO in widget.savingVOList) {
        DropDownValueModel model = DropDownValueModel(
          name: savingVO.saving.name ?? '-',
          value: savingVO,
        );

        if (widget.commitmentDetailVO.referredSavingVO != null &&
            widget.commitmentDetailVO.referredSavingVO!.savingId != null &&
            savingVO.saving.id ==
                widget.commitmentDetailVO.referredSavingVO!.savingId!) {
          _commitmentReferredSavingController.dropDownValue = model;
        }

        savingDropDownValues.add(model);
      }
    }

    if (widget.commitmentDetailVO.amount != null) {
      _amountController.text = widget.commitmentDetailVO.amount!.toString();
    }

    if (widget.commitmentDetailVO.description != null) {
      _descriptionController.text = widget.commitmentDetailVO.description!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _formFields.clear();
    _formFields.addAll([
      IThInputTextFormFields(
        label: 'Description',
        controller: _descriptionController,
      ),
      IThInputTextFormFields(label: 'Amount', controller: _amountController),
      IThInputSelectOneFormFields(
        dropDownValues: savingDropDownValues,
        controller: _commitmentReferredSavingController,
        withLabel: true,
        label: 'Savings',
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

  Future<void> onSave() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      showSnackBarMessage(context, 'Please fill every field');
      return;
    }

    if (_amountController.text.isEmpty) {
      showSnackBarMessage(context, 'Please insert the amount');
      return;
    }

    try {
      double.parse(_amountController.text);
    } catch (e) {
      showSnackBarMessage(context, 'Please insert valid amount');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      showSnackBarMessage(context, 'Please insert the description');
      return;
    }

    if (_commitmentReferredSavingController.dropDownValue == null) {
      showSnackBarMessage(context, 'Please select the referred saving');
      return;
    }

    SavingVO referredSavingVO = SavingVO.fromSvngSaving(
      (_commitmentReferredSavingController.dropDownValue!.value as ListSavingVO)
          .saving,
    );

    widget.commitmentDetailVO.description = _descriptionController.text;
    widget.commitmentDetailVO.referredSavingVO = referredSavingVO;
    widget.commitmentDetailVO.amount = double.parse(_amountController.text);

    BlocProvider.of<CommitmentBloc>(
      context,
    ).add(SaveCommitmentDetailEvent(toBeSaved: widget.commitmentDetailVO));
  }

  List<Widget> _setFormFields(BuildContext context) {
    List<Widget> fields = [];
    for (IThWidget widget in _formFields) {
      fields.add(_inputField(widget, context));
      fields.add(IThVerticalSpacingFormFields(height: 20.0));
    }
    return fields;
  }

  Widget _inputField(Widget widget, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [widget],
      ),
    );
  }
}
