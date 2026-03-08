part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when a bottom nav item is tapped
class NavigationTabTapped extends NavigationEvent {
  final int index;
  final BuildContext context;

  const NavigationTabTapped({required this.index, required this.context});

  @override
  List<Object?> get props => [index];
}

/// Dispatched when returning from a pushed route — resets index to Home (0)
class NavigationReturned extends NavigationEvent {
  const NavigationReturned();
}

class OpenNavigationEvent extends NavigationEvent {}

class CloseNavigationEvent extends NavigationEvent {}

class ToggleNavigationEvent extends NavigationEvent {}

class NavigateToScreenEvent extends NavigationEvent {
  final String route;
  final Map<String, dynamic>? extraData;

  const NavigateToScreenEvent(this.route, {this.extraData});

  @override
  List<Object?> get props => [route, extraData];
}

class RefreshDashboardEvent extends NavigationEvent {}
