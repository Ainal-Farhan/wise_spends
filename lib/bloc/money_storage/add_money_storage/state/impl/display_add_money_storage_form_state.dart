import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/forms/money_storage/i_th_add_money_storage_form.dart';

class DisplayAddMoneyStorageFormState extends AddMoneyStorageState {
  const DisplayAddMoneyStorageFormState({required int version})
      : super(version: version);

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
                  Ink(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(400.0),
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRouter.viewListMoneyStoragePageRoute,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 30.0,
                          color: Colors.black,
                        ),
                      ),
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
  AddMoneyStorageState getNewVersion() =>
      DisplayAddMoneyStorageFormState(version: version + 1);

  @override
  AddMoneyStorageState getStateCopy() =>
      DisplayAddMoneyStorageFormState(version: version);
}
