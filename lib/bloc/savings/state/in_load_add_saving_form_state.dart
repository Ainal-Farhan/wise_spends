import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/forms/saving/i_th_add_saving_form.dart';

class InLoadAddSavingFormState extends IState<InLoadAddSavingFormState> {
  final List<DropDownValueModel> moneyStorageList;

  const InLoadAddSavingFormState({
    required super.version,
    required this.moneyStorageList,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: screenHeight * 0.1,
          child: Container(),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .7,
            child: IThAddSavingForm(
              moneyStorageList: moneyStorageList,
              savingTypeList: SavingTableType.retrieveAllAsDropDownValueModel(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IThBackButtonRound(
                    onTap: () => BlocProvider.of<SavingsBloc>(context)
                        .add(LoadListSavingsEvent()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  InLoadAddSavingFormState getNewVersion() => InLoadAddSavingFormState(
        version: version + 1,
        moneyStorageList: [...moneyStorageList],
      );

  @override
  InLoadAddSavingFormState getStateCopy() => InLoadAddSavingFormState(
        version: version,
        moneyStorageList: [...moneyStorageList],
      );
}
