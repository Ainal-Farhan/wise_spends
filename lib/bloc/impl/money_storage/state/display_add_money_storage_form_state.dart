import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/money_storage/events/in_load_view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/theme/widgets/components/buttons/th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/forms/money_storage/th_add_money_storage_form.dart';

class DisplayAddMoneyStorageFormState
    extends IState<DisplayAddMoneyStorageFormState> {
  const DisplayAddMoneyStorageFormState({required super.version});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Center(
            child: SizedBox(
              height: screenHeight * .7,
              child: ThAddMoneyStorageForm(),
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
                    ThBackButtonRound(
                      onTap: () => BlocProvider.of<MoneyStorageBloc>(
                        context,
                      ).add(InLoadViewListMoneyStorageEvent()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  DisplayAddMoneyStorageFormState getNewVersion() =>
      DisplayAddMoneyStorageFormState(version: version + 1);

  @override
  DisplayAddMoneyStorageFormState getStateCopy() =>
      DisplayAddMoneyStorageFormState(version: version);
}
