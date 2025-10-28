import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/savings/components/saving_transaction/saving_transaction_form_widget.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/theme/widgets/components/buttons/th_back_button_round.dart';

class InSavingTransactionFormState
    extends IState<InSavingTransactionFormState> {
  final SvngSaving saving;

  const InSavingTransactionFormState({
    required this.saving,
    required super.version,
  });

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
              child: SavingTransactionFormWidget(saving: saving),
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
                      onTap: () => BlocProvider.of<SavingsBloc>(
                        context,
                      ).add(LoadListSavingsEvent()),
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
  InSavingTransactionFormState getNewVersion() => InSavingTransactionFormState(
    version: version + 1,
    saving: SvngSaving.fromJson(saving.toJson()),
  );

  @override
  InSavingTransactionFormState getStateCopy() =>
      InSavingTransactionFormState(version: version, saving: saving);
}
