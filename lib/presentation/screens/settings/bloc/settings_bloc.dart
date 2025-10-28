import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoaded());
  }
}
