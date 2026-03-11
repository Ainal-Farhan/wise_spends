part of 'widget_settings_cubit.dart';

class WidgetSettingsState {
  final bool isQuickAccessEnabled;
  final bool isHideDetailsEnabled;

  const WidgetSettingsState({
    this.isQuickAccessEnabled = true,
    this.isHideDetailsEnabled = false,
  });

  WidgetSettingsState copyWith({
    bool? isQuickAccessEnabled,
    bool? isHideDetailsEnabled,
  }) {
    return WidgetSettingsState(
      isQuickAccessEnabled: isQuickAccessEnabled ?? this.isQuickAccessEnabled,
      isHideDetailsEnabled: isHideDetailsEnabled ?? this.isHideDetailsEnabled,
    );
  }
}
