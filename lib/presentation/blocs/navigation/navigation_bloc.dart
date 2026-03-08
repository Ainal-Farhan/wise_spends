import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationClosed()) {
    on<OpenNavigationEvent>(_onOpen);
    on<CloseNavigationEvent>(_onClose);
    on<ToggleNavigationEvent>(_onToggle);
    on<NavigateToScreenEvent>(_onNavigate);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  void _onOpen(OpenNavigationEvent event, Emitter<NavigationState> emit) {
    emit(NavigationOpened());
  }

  void _onClose(CloseNavigationEvent event, Emitter<NavigationState> emit) {
    emit(NavigationClosed());
  }

  void _onToggle(ToggleNavigationEvent event, Emitter<NavigationState> emit) {
    if (state is NavigationOpened) {
      emit(NavigationClosed());
    } else {
      emit(NavigationOpened());
    }
  }

  Future<void> _onNavigate(
    NavigateToScreenEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationNavigating(event.route, extraData: event.extraData));
    await Future.delayed(const Duration(milliseconds: 300));
    if (!isClosed && !emit.isDone) emit(NavigationClosed());
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(DashboardRefreshRequested());
    await Future.delayed(const Duration(milliseconds: 100));
    if (!isClosed && !emit.isDone) emit(NavigationClosed());
  }
}
