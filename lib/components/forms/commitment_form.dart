import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/save_commitment_event.dart';
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
  final TextEditingController _descriptionController = TextEditingController();
  final SingleValueDropDownController _commitmentReferredSavingController =
      SingleValueDropDownController();

  final List<IThWidget> _formFields = [];
  final List<DropDownValueModel> savingDropDownValues = [];

  @override
  void initState() {
    if (widget.savingVOList.isNotEmpty) {
      for (ListSavingVO savingVO in widget.savingVOList) {
        savingDropDownValues.add(
          DropDownValueModel(
            name: savingVO.saving.name ?? '-',
            value: savingVO,
          ),
        );
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      if (!_formKey.currentState!.validate()) {
        showSnackBarMessage(context, 'Please fill every field');
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
          (_commitmentReferredSavingController.dropDownValue!.value
                  as ListSavingVO)
              .saving);

      widget.commitmentVO.description = _descriptionController.text;
      widget.commitmentVO.referredSavingVO = referredSavingVO;

      BlocProvider.of<CommitmentBloc>(context)
          .add(SaveCommitmentEvent(toBeSaved: widget.commitmentVO));
    }

    _formFields.clear();
    _formFields.addAll([
      IThInputTextFormFields(
        label: 'Description',
        controller: _descriptionController,
      ),
      IThInputSelectOneFormFields(
        dropDownValues: savingDropDownValues,
        controller: _commitmentReferredSavingController,
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
