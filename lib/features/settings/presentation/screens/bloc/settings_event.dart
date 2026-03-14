part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class ChangeThemeEvent extends SettingsEvent {
  final ThemeMode themeMode;
  const ChangeThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ChangeLanguageEvent extends SettingsEvent {
  final String languageCode;
  const ChangeLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}
