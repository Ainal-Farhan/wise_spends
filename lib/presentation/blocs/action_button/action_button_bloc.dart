import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/core/constants/extra_constants/hero_tags.dart';

part 'action_button_event.dart';
part 'action_button_state.dart';

class ActionButtonBloc extends Bloc<ActionButtonEvent, ActionButtonState> {
  ActionButtonBloc() : super(ActionButtonInitialState()) {
    on<OnUpdateActionButtonEvent>((event, emit) {
      final List<FloatingActionButton> actionButtonList = [];
      if (event.actionButtonMap != null) {
        final context = event.context;
        for (final map in event.actionButtonMap!.entries) {
          final onPressed = map.value;
          final actionButtonEnum = map.key;
          FloatingActionButton? fab;
          switch (actionButtonEnum) {
            case ActionButtonEnum.addNewSaving:
              fab = FloatingActionButton(
                heroTag: HeroTagConstants.viewSavingForm,
                onPressed: onPressed,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add),
              );
              break;
            case ActionButtonEnum.displayCommitment:
              fab = FloatingActionButton(
                heroTag: HeroTagConstants.displayCommitment,
                onPressed: onPressed,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add),
              );
              break;
            case ActionButtonEnum.backToCommitments:
              fab = FloatingActionButton(
                heroTag: HeroTagConstants.backToCommitments,
                onPressed: onPressed,
                backgroundColor: Colors.grey,
                child: const Icon(Icons.arrow_back),
              );

              break;
            case ActionButtonEnum.addCommitmentDetail:
              fab = FloatingActionButton(
                heroTag: HeroTagConstants.addCommitmentDetail,
                onPressed: onPressed,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add),
              );
              break;
            case ActionButtonEnum.addMoneyStorage:
              fab = FloatingActionButton(
                onPressed: onPressed,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add),
              );
              break;
            case ActionButtonEnum.backButton:
              fab = FloatingActionButton(
                heroTag: HeroTagConstants.backButton,
                onPressed: onPressed,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.arrow_back),
              );
          }

          actionButtonList.add(fab);
        }
      }
      emit(ActionButtonsLoaded(floatingActionButtonList: actionButtonList));
    });
  }
}
