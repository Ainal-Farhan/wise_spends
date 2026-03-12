import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavBarCubit extends Cubit<int> {
  BottomNavBarCubit() : super(0);

  void setIndex(int index) => emit(index);

  void hide() => emit(-1);

  void show() => emit(0);
}
