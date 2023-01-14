import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/forms/saving/i_th_edit_saving_form.dart';

/// Initialized
class InEditSavingsState extends EditSavingsState {
  const InEditSavingsState(int version, this.saving) : super(version: version);

  final SvngSaving saving;

  @override
  String toString() => 'InEditSavingsState';

  @override
  InEditSavingsState getStateCopy() {
    return InEditSavingsState(version, saving);
  }

  @override
  InEditSavingsState getNewVersion() {
    return InEditSavingsState(version + 1, saving);
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
            child: IThEditSavingForm(saving: saving),
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
                        AppRouter.savingsPageRoute,
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
}
