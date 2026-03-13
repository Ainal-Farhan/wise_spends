part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class OpenNavigationEvent extends NavigationEvent {}

class CloseNavigationEvent extends NavigationEvent {}

class ToggleNavigationEvent extends NavigationEvent {}

class NavigateToScreenEvent extends NavigationEvent {
  final String route;
  final Object? extraData;

  const NavigateToScreenEvent(this.route, {this.extraData});

  @override
  List<Object?> get props => [route, extraData];
}

class RefreshDashboardEvent extends NavigationEvent {}

/// Fired when the profile is reloaded (e.g. after editing)
/// so the sidebar avatar/name updates without a full rebuild.
class RefreshSidebarProfileEvent extends NavigationEvent {}
