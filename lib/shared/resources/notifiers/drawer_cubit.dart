import 'package:flutter_bloc/flutter_bloc.dart';

class DrawerCubit extends Cubit<DrawerState> {
  DrawerCubit()
    : super(const DrawerState(selectedIndex: -1, isExpanded: false));

  void setSelectedIndex(int index) =>
      emit(state.copyWith(selectedIndex: index));

  void toggleExpanded() => emit(state.copyWith(isExpanded: !state.isExpanded));

  void setExpanded(bool expanded) => emit(state.copyWith(isExpanded: expanded));
}

class DrawerState {
  final int selectedIndex;
  final bool isExpanded;

  const DrawerState({required this.selectedIndex, required this.isExpanded});

  DrawerState copyWith({int? selectedIndex, bool? isExpanded}) {
    return DrawerState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
