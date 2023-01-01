abstract class IConfigurationManager {
  Future<void> update({
    String? theme,
    String? language,
  });

  Future<String> getTheme();
}
