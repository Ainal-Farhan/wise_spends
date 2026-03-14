import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/services/preferences_service.dart';
import 'package:wise_spends/features/widget/presentation/services/widget_service.dart';

part 'widget_settings_state.dart';

/// Cubit for home-widget settings.
/// All persistence delegates to [PreferencesService] — no direct
/// [SharedPreferences] access inside this class.
class WidgetSettingsCubit extends Cubit<WidgetSettingsState> {
  WidgetSettingsCubit() : super(const WidgetSettingsState()) {
    _loadPreferences();
  }

  final _prefs = PreferencesService();

  Future<void> _loadPreferences() async {
    await _prefs.init();
    emit(
      state.copyWith(
        isQuickAccessEnabled: _prefs.getWidgetQuickAccessEnabled(),
        isHideDetailsEnabled: _prefs.getWidgetHideDetails(),
      ),
    );
  }

  Future<void> toggleHideDetails({required bool value}) async {
    await _prefs.setWidgetHideDetails(value);
    await WidgetService.setHideDetails(hide: value);
    emit(state.copyWith(isHideDetailsEnabled: value));
  }

  Future<void> toggleQuickAccess({required bool value}) async {
    await _prefs.setWidgetQuickAccessEnabled(value);
    emit(state.copyWith(isQuickAccessEnabled: value));
  }
}
