import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/app_locale.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/services/preferences_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// Central BLoC that owns all user-adjustable settings.
///
/// It exposes two focused [StreamController]s so any widget tree that is not
/// a direct BlocBuilder descendant can also react to changes:
///   • [themeStream]    → consumed by the root [MaterialApp] to rebuild with
///                        the new [ThemeMode] without a full app restart.
///   • [localeStream]   → consumed by the root [MaterialApp] to swap locale
///                        strings without restarting.
///
/// Typical usage in main.dart:
/// ```dart
/// final settingsBloc = SettingsBloc();
///
/// StreamBuilder<ThemeMode>(
///   stream: settingsBloc.themeStream,
///   initialData: ThemeMode.system,
///   builder: (_, snap) => MaterialApp(
///     themeMode: snap.data!,
///     locale: ...,   // driven by localeStream in a nested StreamBuilder
///   ),
/// )
/// ```
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final PreferencesService _prefs;
  final LocalizationService _l10n;

  // ── Public reactive streams ───────────────────────────────────────────────

  /// Emits whenever the active [ThemeMode] changes.
  /// Seeded with the last-saved value as soon as [LoadSettingsEvent] completes.
  final _themeController = StreamController<ThemeMode>.broadcast();
  Stream<ThemeMode> get themeStream => _themeController.stream;

  /// Emits the new [Locale] whenever the active language changes.
  final _localeController = StreamController<Locale>.broadcast();
  Stream<Locale> get localeStream => _localeController.stream;

  SettingsBloc({PreferencesService? prefs, LocalizationService? l10n})
    : _prefs = prefs ?? PreferencesService(),
      _l10n = l10n ?? LocalizationService(),
      super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoad);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  // ── Event handlers ────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _prefs.init();

      final themeMode = _themeModeFromIndex(_prefs.getThemeMode());
      final languageCode = _prefs.getLanguageCode();

      // Push initial values into streams so downstream consumers get them
      // even if they subscribed after the BLoC was created.
      _themeController.add(themeMode);
      _localeController.add(Locale(languageCode));

      emit(SettingsLoaded(themeMode: themeMode, languageCode: languageCode));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    try {
      // Persist
      await _prefs.saveTheme(_themeIndexFromMode(event.themeMode));

      // Notify stream listeners (e.g. MaterialApp wrapper)
      _themeController.add(event.themeMode);

      emit(current.copyWith(themeMode: event.themeMode));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    try {
      final locale = AppLocale.fromCode(event.languageCode);

      // Update in-memory string map + persist
      await _l10n.setLocale(locale);

      // Notify stream listeners (e.g. MaterialApp wrapper)
      _localeController.add(Locale(event.languageCode));

      emit(current.copyWith(languageCode: event.languageCode));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  ThemeMode _themeModeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  int _themeIndexFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  @override
  Future<void> close() {
    _themeController.close();
    _localeController.close();
    return super.close();
  }
}
