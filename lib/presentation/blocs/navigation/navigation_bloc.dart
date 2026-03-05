import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/app_routes.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationTabTapped>(_onTabTapped);
    on<NavigationReturned>(_onReturned);
  }

  Future<void> _onTabTapped(
    NavigationTabTapped event,
    Emitter<NavigationState> emit,
  ) async {
    // Guard against double-taps while already navigating
    if (state.isNavigating) return;
    // Tapping the current tab does nothing
    if (event.index == state.selectedIndex) return;

    emit(state.copyWith(selectedIndex: event.index, isNavigating: true));

    final route = _routeForIndex(event.index);

    if (route != null) {
      await Navigator.pushNamed(event.context, route);
      // Returned from pushed route — reset to Home
      add(const NavigationReturned());
    } else {
      // Index 0 is Home — already there, just clear the lock
      emit(state.copyWith(isNavigating: false));
    }
  }

  void _onReturned(NavigationReturned event, Emitter<NavigationState> emit) {
    emit(const NavigationState(selectedIndex: 0, isNavigating: false));
  }

  String? _routeForIndex(int index) {
    switch (index) {
      case 1:
        return AppRoutes.budgetList;
      case 2:
        return AppRoutes.savings;
      case 3:
        return AppRoutes.moneyStorage;
      case 4:
        return AppRoutes.settings;
      default:
        return null; // 0 = Home, no push needed
    }
  }
}
