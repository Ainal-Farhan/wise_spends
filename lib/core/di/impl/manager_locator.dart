import 'package:wise_spends/core/config/configuration/configuration_manager.dart';
import 'package:wise_spends/core/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/domain/usecases/i_commitment_manager.dart';
import 'package:wise_spends/domain/usecases/i_home_logged_in_manager.dart';
import 'package:wise_spends/domain/usecases/i_login_manager.dart';
import 'package:wise_spends/domain/usecases/i_saving_manager.dart';
import 'package:wise_spends/domain/usecases/i_startup_manager.dart';
import 'package:wise_spends/domain/usecases/i_transaction_manager.dart';
import 'package:wise_spends/domain/usecases/impl/commitment_manager.dart';
import 'package:wise_spends/domain/usecases/impl/home_logged_in_manager.dart';
import 'package:wise_spends/domain/usecases/impl/login_manager.dart';
import 'package:wise_spends/domain/usecases/impl/saving_manager.dart';
import 'package:wise_spends/domain/usecases/impl/startup_manager.dart';
import 'package:wise_spends/domain/usecases/impl/transaction_manager.dart';
import 'package:wise_spends/shared/theme/i_theme_manager.dart';
import 'package:wise_spends/shared/theme/theme_manager.dart';

class ManagerLocator extends IManagerLocator {
  @override
  IHomeLoggedInManager getHomeLoggedInManager() {
    IHomeLoggedInManager? manager =
        SingletonUtil.getSingleton<IHomeLoggedInManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<IHomeLoggedInManager>(
          HomeLoggedInManager());
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
      SingletonUtil.registerSingleton<ITransactionManager>(
          TransactionManager());
    }

    return SingletonUtil.getSingleton<ITransactionManager>()!;
  }

  @override
  IConfigurationManager getConfigurationManager() {
    IConfigurationManager? manager =
        SingletonUtil.getSingleton<IConfigurationManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<IConfigurationManager>(
          ConfigurationManager());
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

  @override
  ICommitmentManager getCommitmentManager() {
    ICommitmentManager? manager =
        SingletonUtil.getSingleton<ICommitmentManager>();

    if (manager == null) {
      SingletonUtil.registerSingleton<ICommitmentManager>(CommitmentManager());
    }

    return SingletonUtil.getSingleton<ICommitmentManager>()!;
  }
}
