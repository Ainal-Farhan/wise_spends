import 'package:wise_spends/manager/i_manager.dart';

abstract class IConfigurationManager extends IManager {
  Future<void> init();

  Future<void> update({
    String? theme,
    String? language,
  });

  String getTheme();
}
