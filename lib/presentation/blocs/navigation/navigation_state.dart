part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

class NavigationIndexState extends NavigationState {
  final int selectedIndex;
  final bool isNavigating;

  const NavigationIndexState({
    this.selectedIndex = 0,
    this.isNavigating = false,
  });

  NavigationIndexState copyWith({int? selectedIndex, bool? isNavigating}) {
    return NavigationIndexState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }

  @override
  List<Object?> get props => [selectedIndex, isNavigating];
}

class NavigationInitial extends NavigationState {}

class NavigationOpened extends NavigationState {}

class NavigationClosed extends NavigationState {}

class NavigationNavigating extends NavigationState {
  final String route;
  final Map<String, dynamic>? extraData;

  const NavigationNavigating(this.route, {this.extraData});

  @override
  List<Object?> get props => [route, extraData];
}

class DashboardRefreshRequested extends NavigationState {}
