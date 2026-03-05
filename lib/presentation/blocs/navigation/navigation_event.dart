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
