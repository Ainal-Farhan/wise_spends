import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wise_spends/presentation/services/widget_service.dart';

part 'widget_settings_state.dart';

class WidgetSettingsCubit extends Cubit<WidgetSettingsState> {
  static const String _quickAccessKey = 'quick_access_button_enabled';

  WidgetSettingsCubit() : super(const WidgetSettingsState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    emit(
      state.copyWith(
        isQuickAccessEnabled:
            prefs.getBool('quick_access_button_enabled') ?? true,
        isHideDetailsEnabled: prefs.getBool('widget_hide_details') ?? false,
      ),
    );
  }

  Future<void> toggleHideDetails({required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widget_hide_details', value);
    await WidgetService.setHideDetails(hide: value);
    emit(state.copyWith(isHideDetailsEnabled: value));
  }

  Future<void> toggleQuickAccess({required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quickAccessKey, value);
    emit(state.copyWith(isQuickAccessEnabled: value));
  }
}
