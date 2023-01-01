class ConfigurationModel {
  String? theme;
  String? language;

  ConfigurationModel({
    required this.theme,
    required this.language,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      language: json['language'],
      theme: json['theme'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'theme': theme,
      'language': language,
    };
  }
}
