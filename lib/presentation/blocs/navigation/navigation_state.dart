part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

class NavigationClosed extends NavigationState {}

class NavigationOpened extends NavigationState {}

class NavigationNavigating extends NavigationState {
  final String route;
  final Object? extraData;

  const NavigationNavigating(this.route, {this.extraData});

  @override
  List<Object?> get props => [route, extraData];
}

class DashboardRefreshRequested extends NavigationState {}

/// Carries fresh profile data so the sidebar header re-renders.
class SidebarProfileLoaded extends NavigationState {
  final UserProfile profile;

  const SidebarProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}
