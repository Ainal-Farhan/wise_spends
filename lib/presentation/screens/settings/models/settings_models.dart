import 'package:flutter/material.dart';

/// Settings item model
class SettingsItem {
  final String id;
  final IconData icon;
  final String title;
  final String? subtitle;
  final SettingsItemType type;
  final bool isDestructive;
  final bool isDisabled;
  final bool showComingSoon;
  final VoidCallback? onTap;
  final dynamic metadata;

  const SettingsItem({
    required this.id,
    required this.icon,
    required this.title,
    this.subtitle,
    this.type = SettingsItemType.navigation,
    this.isDestructive = false,
    this.isDisabled = false,
    this.showComingSoon = false,
    this.onTap,
    this.metadata,
  });

  /// Create a navigation item
  const SettingsItem.navigation({
    required this.id,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.metadata,
  })  : type = SettingsItemType.navigation,
        isDestructive = false,
        isDisabled = false,
        showComingSoon = false;

  /// Create a coming soon item
  const SettingsItem.comingSoon({
    required this.id,
    required this.icon,
    required this.title,
    this.subtitle,
  })  : type = SettingsItemType.navigation,
        isDestructive = false,
        isDisabled = true,
        showComingSoon = true,
        onTap = null,
        metadata = null;

  /// Create a destructive item
  const SettingsItem.destructive({
    required this.id,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  })  : type = SettingsItemType.navigation,
        isDestructive = true,
        isDisabled = false,
        showComingSoon = false,
        metadata = null;
}

/// Settings item type
enum SettingsItemType {
  navigation,
  toggle,
  action,
  divider,
}

/// Settings section data model
class SettingsSectionData {
  final String id;
  final String title;
  final String? description;
  final List<SettingsItem> items;

  const SettingsSectionData({
    required this.id,
    required this.title,
    this.description,
    required this.items,
  });
}

/// Theme option model
class ThemeOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode themeMode;

  const ThemeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeMode,
  });

  static const List<ThemeOption> options = [
    ThemeOption(
      id: 'light',
      title: 'Light',
      subtitle: 'Always use light theme',
      icon: Icons.light_mode_outlined,
      themeMode: ThemeMode.light,
    ),
    ThemeOption(
      id: 'dark',
      title: 'Dark',
      subtitle: 'Always use dark theme',
      icon: Icons.dark_mode_outlined,
      themeMode: ThemeMode.dark,
    ),
    ThemeOption(
      id: 'system',
      title: 'System',
      subtitle: 'Follow device theme',
      icon: Icons.settings_suggest_outlined,
      themeMode: ThemeMode.system,
    ),
  ];
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const List<LanguageOption> options = [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    LanguageOption(
      code: 'ms',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
      flag: '🇲🇾',
    ),
    LanguageOption(
      code: 'zh',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      flag: '🇨🇳',
    ),
    LanguageOption(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
    ),
  ];
}
