import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/app_locale.dart';
import 'package:wise_spends/core/services/preferences_service.dart';
import 'package:wise_spends/shared/resources/l10n/strings_en.dart';
import 'package:wise_spends/shared/resources/l10n/strings_ms.dart';

/// Localization service providing translated strings.
///
/// ### Why a stream?
/// The `.tr` extension resolves strings **at widget build time** by reading
/// directly from this singleton's `_strings` map. Swapping the map alone is
/// not enough — every widget that used `.tr` has already rendered and holds
/// the old string. The only way to get them to re-render is to trigger a
/// rebuild of the widget tree above them.
///
/// [localeChangeStream] emits whenever [setLocale] is called. The root
/// [_AppRoot] in `main.dart` wraps [MaterialApp] in a [StreamBuilder] on
/// this stream, so a language change causes the entire app subtree to rebuild
/// from the top — guaranteeing every `.tr` call evaluates against the new map.
class LocalizationService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal() {
    _loadSavedLocale();
  }

  // ── State ──────────────────────────────────────────────────────────────────
  AppLocale _currentLocale = AppLocale.english;
  Map<String, String> _strings = EnglishStrings.strings;

  // ── Stream ─────────────────────────────────────────────────────────────────

  /// Broadcast stream that emits the new [Locale] every time [setLocale] is
  /// called. Subscribe to this in the root widget to force a full rebuild.
  ///
  /// [SettingsBloc] forwards this stream as its own `localeStream`, so
  /// callers can subscribe to either — both point at the same source.
  final _localeController = StreamController<Locale>.broadcast();
  Stream<Locale> get localeChangeStream => _localeController.stream;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> _loadSavedLocale() async {
    final prefs = PreferencesService();
    await prefs.init();
    _currentLocale = prefs.getAppLocale();
    _strings = _stringsFor(_currentLocale);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  AppLocale get currentLocale => _currentLocale;
  Map<String, String> get strings => _strings;
  bool get isMalay => _currentLocale == AppLocale.malay;
  bool get isEnglish => _currentLocale == AppLocale.english;

  String getLocaleDisplayName(AppLocale locale) => locale.nativeName;

  /// Swap the active locale, persist it, and broadcast a change event so the
  /// root widget rebuilds the entire app tree, forcing all `.tr` calls to
  /// re-evaluate with the new string map.
  Future<void> setLocale(AppLocale locale) async {
    _currentLocale = locale;
    _strings = _stringsFor(locale);

    // Persist
    final prefs = PreferencesService();
    await prefs.saveLanguage(locale.code);

    // Notify — this triggers the StreamBuilder in _AppRoot (main.dart)
    // which rebuilds MaterialApp and everything beneath it.
    _localeController.add(Locale(locale.code));
  }

  /// Look up a localized string by [key].
  /// Falls back to English, then the key itself if not found.
  String get(String key, [Map<String, String>? params]) {
    String value = _strings[key] ?? EnglishStrings.strings[key] ?? key;
    if (params != null) {
      params.forEach((k, v) => value = value.replaceAll('{$k}', v));
    }
    return value;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Map<String, String> _stringsFor(AppLocale locale) {
    switch (locale) {
      case AppLocale.malay:
        return MalayStrings.strings;
      case AppLocale.english:
        return EnglishStrings.strings;
    }
  }

  void dispose() {
    _localeController.close();
  }
}

// ── Convenience extensions ─────────────────────────────────────────────────────

extension LocalizationExtension on String {
  /// Returns the localized value for this key from the active string map.
  /// Because this is called inside `build()`, it always reads the current map
  /// as long as the widget has been rebuilt after a locale change.
  String get tr => LocalizationService().get(this);

  String trWith(Map<String, String> params) =>
      LocalizationService().get(this, params);
}
