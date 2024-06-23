import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/forms/money_storage/i_th_add_money_storage_form.dart';

class DisplayAddMoneyStorageFormState extends IState<DisplayAddMoneyStorageFormState> {
  const DisplayAddMoneyStorageFormState({required super.version});

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
            child: IThAddMoneyStorageForm(),
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
                          )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  DisplayAddMoneyStorageFormState getNewVersion() =>
      DisplayAddMoneyStorageFormState(version: version + 1);

  @override
  DisplayAddMoneyStorageFormState getStateCopy() =>
      DisplayAddMoneyStorageFormState(version: version);
}
