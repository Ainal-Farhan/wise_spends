abstract class IConfigurationManager {
  Future<void> init();

  Future<void> update({
    String? theme,
    String? language,
  });

  String getTheme();
}
