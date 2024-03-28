import 'package:wise_spends/constant/app/config_constant.dart';

class ConfigurationModel {
  String? theme;
  String? language;

  ConfigurationModel({
    required this.theme,
    required this.language,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      language: json[ConfigConstant.jsonLabelLanguage],
      theme: json[ConfigConstant.jsonLabelTheme],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ConfigConstant.jsonLabelLanguage: theme,
      ConfigConstant.jsonLabelTheme: language,
    };
  }
}
