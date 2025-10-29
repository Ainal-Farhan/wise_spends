import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';
import 'package:wise_spends/shared/theme/widgets/components/buttons/th_save_button.dart';
import 'package:wise_spends/shared/theme/widgets/components/form_fields/th_input_select_one_form_fields.dart';
import 'package:wise_spends/shared/theme/widgets/components/form_fields/th_input_text_form_fields.dart';
import 'package:wise_spends/shared/theme/widgets/components/form_fields/th_vertical_spacing_form_fields.dart';

class CommitmentDetailForm extends StatefulWidget {
  final String commitmentId;
  final CommitmentDetailVO commitmentDetailVO;
  final List<ListSavingVO> savingVOList;

  const CommitmentDetailForm({
    required this.commitmentId,
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

  final List<Widget> _formFields = [];
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
      ThInputTextFormFields(
        label: 'Description',
        hint: 'Enter description',
        controller: _descriptionController,
      ),
      ThInputTextFormFields(
        label: 'Amount',
        hint: 'Enter amount',
        controller: _amountController,
        keyboardType: TextInputType.number,
      ),
      ThInputSelectOneFormFields(
        label: 'Savings',
        hint: 'Select a saving',
        value: _commitmentReferredSavingController.dropDownValue?.name,
        options: savingDropDownValues.map((e) => e.name).toList(),
        onChanged: (value) {
          var selected = savingDropDownValues.firstWhere(
            (e) => e.name == value,
          );
          _commitmentReferredSavingController.dropDownValue = selected;
        },
      ),
    ]);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ..._setFormFields(context),
            ThSaveButton(onTap: onSave),
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

    BlocProvider.of<CommitmentBloc>(context).add(
      SaveCommitmentDetailEvent(
        commitmentDetailVO: widget.commitmentDetailVO,
        commitmentId: widget.commitmentId,
      ),
    );
  }

  List<Widget> _setFormFields(BuildContext context) {
    List<Widget> fields = [];
    for (Widget widget in _formFields) {
      fields.add(_inputField(widget, context));
      fields.add(ThVerticalSpacingFormFields(height: 20.0));
    }
    return fields;
  }

  Widget _inputField(Widget widget, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: widget, // no Row wrapper!
    );
  }
}
