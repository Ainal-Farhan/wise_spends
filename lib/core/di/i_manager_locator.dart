import 'package:wise_spends/core/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/core/di/i_locator.dart';
import 'package:wise_spends/domain/usecases/i_commitment_manager.dart';
import 'package:wise_spends/domain/usecases/i_home_logged_in_manager.dart';
import 'package:wise_spends/domain/usecases/i_login_manager.dart';
import 'package:wise_spends/domain/usecases/i_saving_manager.dart';
import 'package:wise_spends/domain/usecases/i_startup_manager.dart';
import 'package:wise_spends/domain/usecases/i_transaction_manager.dart';
import 'package:wise_spends/shared/theme/i_theme_manager.dart';

abstract class IManagerLocator extends ILocator {
  IHomeLoggedInManager getHomeLoggedInManager();
  ILoginManager getLoginManager();
  ISavingManager getSavingManager();
  IStartupManager getStartupManager();
  ITransactionManager getTransactionManager();
  IConfigurationManager getConfigurationManager();
  IThemeManager getThemeManager();
  ICommitmentManager getCommitmentManager();
}
