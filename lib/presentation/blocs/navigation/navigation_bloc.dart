import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final UserRepository _userRepository;

  /// Keeps track of the active route so the sidebar can highlight it.
  String _activeRoute = '';
  String get activeRoute => _activeRoute;

  NavigationBloc({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository(),
      super(NavigationClosed()) {
    on<OpenNavigationEvent>(_onOpen);
    on<CloseNavigationEvent>(_onClose);
    on<ToggleNavigationEvent>(_onToggle);
    on<NavigateToScreenEvent>(_onNavigate);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
    on<RefreshSidebarProfileEvent>(_onRefreshSidebarProfile);
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  void _onOpen(OpenNavigationEvent event, Emitter<NavigationState> emit) {
    emit(NavigationOpened());
  }

  void _onClose(CloseNavigationEvent event, Emitter<NavigationState> emit) {
    emit(NavigationClosed());
  }

  void _onToggle(ToggleNavigationEvent event, Emitter<NavigationState> emit) {
    emit(state is NavigationOpened ? NavigationClosed() : NavigationOpened());
  }

  Future<void> _onNavigate(
    NavigateToScreenEvent event,
    Emitter<NavigationState> emit,
  ) async {
    _activeRoute = event.route;
    emit(NavigationNavigating(event.route, extraData: event.extraData));
    await Future.delayed(const Duration(milliseconds: 300));
    if (!isClosed) emit(NavigationClosed());
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(DashboardRefreshRequested());
    await Future.delayed(const Duration(milliseconds: 100));
    if (!isClosed) emit(NavigationClosed());
  }

  Future<void> _onRefreshSidebarProfile(
    RefreshSidebarProfileEvent event,
    Emitter<NavigationState> emit,
  ) async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null && !isClosed) {
        emit(SidebarProfileLoaded(UserProfile.fromCmmnUser(user)));
        // Briefly hold the loaded state so the UI can read it,
        // then settle back to whatever open/closed we were before.
        await Future.delayed(const Duration(milliseconds: 50));
        if (!isClosed) emit(NavigationClosed());
      }
    } catch (_) {
      // Non-fatal — sidebar will retain its previous display values.
    }
  }
}
