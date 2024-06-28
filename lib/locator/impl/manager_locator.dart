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
    IHomeLoggedInManager? manager =
        SingletonUtil.getSingleton<IHomeLoggedInManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<IHomeLoggedInManager>(HomeLoggedInManager());
    }

    return SingletonUtil.getSingleton<IHomeLoggedInManager>()!;
  }

  @override
  ILoginManager getLoginManager() {
    ILoginManager? manager = SingletonUtil.getSingleton<ILoginManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<ILoginManager>(LoginManager());
    }

    return SingletonUtil.getSingleton<ILoginManager>()!;
  }

  @override
  ISavingManager getSavingManager() {
    ISavingManager? manager = SingletonUtil.getSingleton<ISavingManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<ISavingManager>(SavingManager());
    }

    return SingletonUtil.getSingleton<ISavingManager>()!;
  }

  @override
  IStartupManager getStartupManager() {
    IStartupManager? manager = SingletonUtil.getSingleton<IStartupManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<IStartupManager>(StartupManager());
    }

    return SingletonUtil.getSingleton<IStartupManager>()!;
  }

  @override
  ITransactionManager getTransactionManager() {
    ITransactionManager? manager =
        SingletonUtil.getSingleton<ITransactionManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<ITransactionManager>(TransactionManager());
    }

    return SingletonUtil.getSingleton<ITransactionManager>()!;
  }

  @override
  IConfigurationManager getConfigurationManager() {
    IConfigurationManager? manager =
        SingletonUtil.getSingleton<IConfigurationManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<IConfigurationManager>(ConfigurationManager());
    }

    return SingletonUtil.getSingleton<IConfigurationManager>()!;
  }

  @override
  IThemeManager getThemeManager() {
    IThemeManager? manager = SingletonUtil.getSingleton<IThemeManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<IThemeManager>(ThemeManager());
    }

    return SingletonUtil.getSingleton<IThemeManager>()!;
  }
}
