part of 'navigation_bloc.dart';

class NavigationState extends Equatable {
  final int selectedIndex;
  final bool isNavigating;

  const NavigationState({this.selectedIndex = 0, this.isNavigating = false});

  NavigationState copyWith({int? selectedIndex, bool? isNavigating}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }

  @override
  List<Object?> get props => [selectedIndex, isNavigating];
}
