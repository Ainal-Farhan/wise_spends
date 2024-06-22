import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/forms/money_storage/i_th_edit_money_storage_form.dart';
import 'package:wise_spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';

class DisplayEditMoneyStorageFormState extends EditMoneyStorageState {
  final EditMoneyStorageFormVO editMoneyStorageFormVO;

  const DisplayEditMoneyStorageFormState({
    required super.version,
    required this.editMoneyStorageFormVO,
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
            child: IThEditMoneyStorageForm(
              editMoneyStorageFormVO: editMoneyStorageFormVO,
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
                      AppRouter.viewListMoneyStoragePageRoute,
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

  @override
  EditMoneyStorageState getNewVersion() => DisplayEditMoneyStorageFormState(
        version: version + 1,
        editMoneyStorageFormVO: editMoneyStorageFormVO,
      );

  @override
  EditMoneyStorageState getStateCopy() => DisplayEditMoneyStorageFormState(
        version: version,
        editMoneyStorageFormVO: editMoneyStorageFormVO,
      );
}
