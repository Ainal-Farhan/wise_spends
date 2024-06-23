import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/forms/saving/i_th_edit_saving_form.dart';

class InEditSavingsState extends IState<InEditSavingsState> {
  final List<DropDownValueModel> moneyStorageList;
  final SvngSaving saving;

  const InEditSavingsState({
    required super.version,
    required this.saving,
    required this.moneyStorageList,
  });


  @override
  String toString() => 'InEditSavingsState';

  @override
  InEditSavingsState getStateCopy() => InEditSavingsState(
        version: version,
        saving: saving,
        moneyStorageList: [...moneyStorageList],
      );

  @override
  InEditSavingsState getNewVersion() {
    return InEditSavingsState(
      version: version + 1,
      saving: saving,
      moneyStorageList: [...moneyStorageList],
    );
  }

  @override
  List<Object> get props => [version, saving];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: screenHeight * .1,
          child: Container(),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .7,
            child: IThEditSavingForm(
              saving: saving,
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
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRouter.savingsPageRoute,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
