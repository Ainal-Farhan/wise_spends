import 'package:wise_spends/config/configuration/configuration_manager.dart';
import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_home_logged_in_manager.dart';
import 'package:wise_spends/manager/i_login_manager.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/manager/i_transaction_manager.dart';
import 'package:wise_spends/manager/impl/home_logged_in_manager.dart';
import 'package:wise_spends/manager/impl/login_manager.dart';
import 'package:wise_spends/manager/impl/saving_manager.dart';
import 'package:wise_spends/manager/impl/startup_manager.dart';
import 'package:wise_spends/manager/impl/transaction_manager.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/theme/theme_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

class ManagerLocator extends IManagerLocator {
  @override
  IHomeLoggedInManager getHomeLoggedInManager() {
    return SingletonUtil.getSingleton<IHomeLoggedInManager>();
  }

  @override
  ILoginManager getLoginManager() {
    return SingletonUtil.getSingleton<ILoginManager>();
  }

  @override
  ISavingManager getSavingManager() {
    return SingletonUtil.getSingleton<ISavingManager>();
  }

  @override
  IStartupManager getStartupManager() {
    return SingletonUtil.getSingleton<IStartupManager>();
  }

  @override
  ITransactionManager getTransactionManager() {
    return SingletonUtil.getSingleton<ITransactionManager>();
  }

  @override
  IConfigurationManager getConfigurationManager() {
    return SingletonUtil.getSingleton<IConfigurationManager>();
  }

  @override
  IThemeManager getThemeManager() {
    return SingletonUtil.getSingleton<IThemeManager>();
  }

  @override
  void registerLocator() {
    SingletonUtil.registerSingleton<IConfigurationManager>(
        ConfigurationManager());
    SingletonUtil.registerSingleton<IHomeLoggedInManager>(
        HomeLoggedInManager());
    SingletonUtil.registerSingleton<IThemeManager>(ThemeManager());
    SingletonUtil.registerSingleton<ILoginManager>(LoginManager());
    SingletonUtil.registerSingleton<IStartupManager>(StartupManager());
    SingletonUtil.registerSingleton<ISavingManager>(SavingManager());
    SingletonUtil.registerSingleton<ITransactionManager>(TransactionManager());
  }
}
