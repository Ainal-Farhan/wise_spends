import 'dart:io';
import 'dart:convert';

import 'package:wise_spends/core/config/configuration/configuration_model.dart';
import 'package:wise_spends/core/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/core/constants/constant/app/config_constant.dart';
import 'package:wise_spends/core/utils/app_path.dart';
import 'package:wise_spends/core/utils/file_util.dart';

class ConfigurationManager extends IConfigurationManager {
  late File _configFile;
  late ConfigurationModel _configurationModel;

  static final ConfigurationManager _configuration =
      ConfigurationManager._internal();
  ConfigurationManager._internal();

  factory ConfigurationManager() {
    return _configuration;
  }

  Future<void> _refresh() async {
    await init();
  }

  Future<File> _getConfigFile() async {
    String fileNameWithPath =
        (await AppPath().getApplicationDocumentsDirectory()).path +
            ConfigConstant.configFileNameForPath;

    File? configFile = await FileUtil.getFileFromDirectory(
        fileNameWithDirectory: fileNameWithPath);

    if (configFile == null) {
      configFile = File(fileNameWithPath);
      await FileUtil.createFileIntoDirectory(configFile);

      // set default configuration
      await configFile.writeAsString(json.encode(_getDefaultConfig()));
    }

    return configFile;
  }

  Future<void> _initModel() async {
    Map<String, dynamic> jsonMap = json.decode(await _read(_configFile));

    _configurationModel = ConfigurationModel.fromJson(jsonMap);
  }

  Future<String> _read(File configFile) async {
    return await configFile.readAsString();
  }

  Map<String, dynamic> _getDefaultConfig() {
    ConfigurationModel defaultConfigModel = ConfigurationModel(
      theme: ConfigConstant.defaultTheme,
      language: ConfigConstant.defaultLanguage,
    );

    return defaultConfigModel.toJson();
  }

  @override
  Future<void> init() async {
    _configFile = await _getConfigFile();
    await _initModel();
  }

  @override
  Future<void> update({
    String? theme,
    String? language,
  }) async {
    await _refresh();

    if (theme != null && ConfigConstant.themeList.contains(theme)) {
      _configurationModel.theme = theme;
    }
    if (language != null && ConfigConstant.languageList.contains(language)) {
      _configurationModel.language = language;
    }

    await _configFile.writeAsString(json.encode(_configurationModel.toJson()));
  }

  @override
  String getTheme() {
    return _configurationModel.theme ?? ConfigConstant.emptyString;
  }
}
