import 'package:flutter/material.dart';
import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/main.dart';
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

      // Refresh the theme in the app by updating the theme provider
      if (mounted) {
        // Find the ThemeProvider and update the theme
        final themeProvider = ThemeProvider.of(context);
        if (themeProvider != null) {
          themeProvider.updateTheme();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to ${_getThemeDisplayName(theme)}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      body: ListView(
        children: [
          // Theme Settings
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.color_lens,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Theme'),
              subtitle: Text(_getThemeDisplayName(_selectedTheme)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showThemeSelectionDialog();
              },
            ),
          ),
          // App Information
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'App Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.blue, // Using theme primary color
              ),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const ListTile(
              leading: Icon(
                Icons.help,
                color: Colors.blue, // Using theme primary color
              ),
              title: Text('About'),
              subtitle: Text('Wise Spends - Manage your finances'),
            ),
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
        String selectedTheme = _selectedTheme; // Local copy for the dialog
        return AlertDialog(
          title: const Text('Select Theme'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return RadioGroup<String>(
                groupValue: selectedTheme,
                onChanged: (value) {
                  setStateDialog(() {
                    selectedTheme = value!;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Default Theme'),
                      value: 'default',
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    RadioListTile<String>(
                      title: const Text('Dark Theme'),
                      value: 'dark',
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                _changeTheme(selectedTheme);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }
}
