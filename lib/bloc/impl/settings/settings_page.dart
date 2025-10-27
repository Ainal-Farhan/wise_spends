import 'package:flutter/material.dart' hide RadioGroup;
import 'package:group_radio_button/group_radio_button.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final IConfigurationManager _configurationManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getConfigurationManager();

  final IThemeManager _themeManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getThemeManager();

  String _selectedTheme = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  void _loadCurrentTheme() {
    setState(() {
      _selectedTheme = _configurationManager.getTheme();
    });
  }

  void _changeTheme(String theme) async {
    if (theme != _selectedTheme) {
      setState(() {
        _selectedTheme = theme;
      });

      await _configurationManager.update(theme: theme);
      await _themeManager.refresh();

      // Refresh the app to apply new theme by navigating back to main route
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to ${theme.toUpperCase()}'),
            duration: const Duration(seconds: 1),
          ),
        );

        // Wait for the snackbar to show, then rebuild the app
        await Future.delayed(const Duration(seconds: 1));

        // Navigate back to the main route to refresh the app with new theme
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.savingsPageRoute, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Theme Settings'),
            tiles: [
              SettingsTile(
                title: const Text('Theme'),
                description: Text(_getThemeDisplayName(_selectedTheme)),
                leading: const Icon(Icons.color_lens),
                onPressed: (context) {
                  _showThemeSelectionDialog();
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('App Information'),
            tiles: [
              SettingsTile(
                title: const Text('Version'),
                description: const Text('1.0.0'),
                leading: const Icon(Icons.info),
              ),
              SettingsTile(
                title: const Text('About'),
                description: const Text('Wise Spends - Manage your finances'),
                leading: const Icon(Icons.help),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'default':
        return 'Default Theme';
      case 'dark':
        return 'Dark Theme';
      default:
        return 'Default Theme';
    }
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: RadioGroup<String>.builder(
            groupValue: _selectedTheme,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTheme = value;
                });
                _changeTheme(value);
                Navigator.of(context).pop();
              }
            },
            items: const ['default', 'dark'],
            itemBuilder: (item) => RadioButtonBuilder(
              item == 'default' ? 'Default Theme' : 'Dark Theme',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }
}
