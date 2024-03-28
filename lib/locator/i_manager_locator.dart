import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_locator.dart';
import 'package:wise_spends/manager/i_home_logged_in_manager.dart';
import 'package:wise_spends/manager/i_login_manager.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/manager/i_transaction_manager.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';

abstract class IManagerLocator extends ILocator {
  IHomeLoggedInManager getHomeLoggedInManager();
  ILoginManager getLoginManager();
  ISavingManager getSavingManager();
  IStartupManager getStartupManager();
  ITransactionManager getTransactionManager();
  IConfigurationManager getConfigurationManager();
  IThemeManager getThemeManager();
}
