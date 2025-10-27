import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
            duration: Duration(seconds: 1),
          ),
        );
        
        // Wait for the snackbar to show, then rebuild the app
        await Future.delayed(Duration(seconds: 1));
        
        // Navigate back to the main route to refresh the app with new theme
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRouter.savingsPageRoute, 
          (route) => false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Theme Settings'),
            tiles: [
              SettingsTile(
                title: Text('Theme'),
                description: Text(_getThemeDisplayName(_selectedTheme)),
                leading: Icon(Icons.color_lens),
                onPressed: (context) {
                  _showThemeSelectionDialog();
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('App Information'),
            tiles: [
              SettingsTile(
                title: Text('Version'),
                description: Text('1.0.0'),
                leading: Icon(Icons.info),
              ),
              SettingsTile(
                title: Text('About'),
                description: Text('Wise Spends - Manage your finances'),
                leading: Icon(Icons.help),
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
          title: Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Default Theme'),
                value: 'default',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    _changeTheme(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('Dark Theme'),
                value: 'dark',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    _changeTheme(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }
}