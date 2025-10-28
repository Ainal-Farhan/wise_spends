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
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

class CommitmentForm extends StatefulWidget {
  final CommitmentVO commitmentVO;
  final List<ListSavingVO> savingVOList;

  const CommitmentForm({
    required this.commitmentVO,
    required this.savingVOList,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CommitmentFormState();
}

class _CommitmentFormState extends State<CommitmentForm> {
  _CommitmentFormState();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // fields Controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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

        if (widget.commitmentVO.referredSavingVO != null &&
            widget.commitmentVO.referredSavingVO!.savingId != null &&
            savingVO.saving.id ==
                widget.commitmentVO.referredSavingVO!.savingId!) {
          _commitmentReferredSavingController.dropDownValue = model;
        }

        savingDropDownValues.add(model);
      }
    }

    if (widget.commitmentVO.name != null) {
      _nameController.text = widget.commitmentVO.name!;
    }

    if (widget.commitmentVO.description != null) {
      _descriptionController.text = widget.commitmentVO.description!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _formFields.clear();
    _formFields.addAll([
      IThInputTextFormFields(label: 'Name', controller: _nameController),
      IThInputTextFormFields(
        label: 'Description',
        controller: _descriptionController,
      ),
      IThInputSelectOneFormFields(
        dropDownValues: savingDropDownValues,
        controller: _commitmentReferredSavingController,
        withLabel: true,
        label: 'From',
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

    if (_nameController.text.isEmpty) {
      showSnackBarMessage(context, 'Please insert the name');
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

    widget.commitmentVO.name = _nameController.text;
    widget.commitmentVO.description = _descriptionController.text;
    widget.commitmentVO.referredSavingVO = referredSavingVO;

    BlocProvider.of<CommitmentBloc>(
      context,
    ).add(SaveCommitmentEvent(toBeSaved: widget.commitmentVO));
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
