import 'package:flutter/material.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/presentation/screens/commitment/commitment_screen.dart';
import 'package:wise_spends/presentation/screens/home/home_screen.dart';
import 'package:wise_spends/presentation/screens/login/ui/login_page.dart';
import 'package:wise_spends/presentation/screens/profile/profile_screen.dart';
import 'package:wise_spends/presentation/screens/settings/backup_restore/backup_restore_screen.dart';
import 'package:wise_spends/presentation/screens/settings/category_management_screen.dart';
import 'package:wise_spends/presentation/screens/settings/ui/settings_screen_wrapper.dart';
import 'package:wise_spends/presentation/screens/transaction/add_transaction_screen.dart'
    as transaction_screen;
import 'package:wise_spends/presentation/screens/transaction/transaction_history_screen.dart'
    as transaction_history_screen;
import 'package:wise_spends/presentation/screens/transaction/transaction_detail_screen.dart'
    as transaction_detail_screen;
import 'package:wise_spends/presentation/screens/transaction/edit_transaction_screen.dart'
    as edit_transaction_screen;
import 'package:wise_spends/presentation/screens/budget/budget_list_screen.dart'
    as budget_screen;
import 'package:wise_spends/presentation/screens/reports/reports_screen.dart'
    as reports_screen;
import 'package:wise_spends/presentation/screens/savings/savings_screen.dart'
    as savings_screen;
import 'package:wise_spends/presentation/screens/money_storage/money_storage_screen.dart'
    as money_storage_screen;
import 'package:wise_spends/presentation/screens/budget_plan/budget_plans_list_screen.dart'
    as budget_plan_screen;
import 'package:wise_spends/presentation/screens/budget_plan/budget_plans_forms.dart'
    as create_budget_plan_screen;
import 'package:wise_spends/presentation/screens/budget_plan/budget_plan_detail_screen.dart'
    as budget_plan_detail_screen;
import 'package:wise_spends/presentation/screens/notifications/notifications_screen.dart'
    as notifications_screen;
import 'package:wise_spends/presentation/screens/commitment_task/commitment_task_screen.dart'
    as commitment_task_screen;
import 'package:wise_spends/presentation/screens/payee/payee_management_screen.dart'
    as payee_management_screen;
import 'package:wise_spends/presentation/screens/logs/log_viewer_screen.dart';
import 'package:wise_spends/presentation/screens/logs/log_settings_screen.dart';
import 'package:wise_spends/presentation/screens/logs/hidden_utility_menu_screen.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_task_repository.dart';
import 'package:wise_spends/router/route_arguments.dart';

/// Enhanced App Router with typed arguments
/// Uses MaterialPageRoute for now, consider migrating to go_router for production
abstract class AppRouter {
  /// Generate route with typed arguments
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract typed arguments
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes
      case AppRoutes.login:
        return _createRoute(const LoginPage(), settings);

      // Main routes
      case AppRoutes.home:
      case AppRoutes.homeLoggedIn:
        return _createRoute(const HomeScreen(), settings);

      // Transaction routes
      case AppRoutes.addTransaction:
        return _createRoute(
          transaction_screen.AddTransactionScreen(
            args: args is AddTransactionArgs
                ? transaction_screen.AddTransactionScreenArgs(
                    preselectedType: args.preselectedType,
                  )
                : const transaction_screen.AddTransactionScreenArgs(),
          ),
          settings,
        );

      case AppRoutes.transactionDetail:
        if (args is TransactionDetailArgs) {
          return _createRoute(
            transaction_detail_screen.TransactionDetailScreen(
              transactionId: args.transactionId,
            ),
            settings,
          );
        }
        return _createRoute(
          _ErrorScreen(message: 'Invalid transaction details arguments'),
          settings,
        );

      case AppRoutes.editTransaction:
        if (args is EditTransactionArgs) {
          return _createRoute(
            edit_transaction_screen.EditTransactionScreen(
              transactionId: args.transactionId,
            ),
            settings,
          );
        }
        return _createRoute(
          _ErrorScreen(message: 'Invalid edit transaction arguments'),
          settings,
        );

      case AppRoutes.transactionHistory:
        return _createRoute(
          const transaction_history_screen.TransactionHistoryScreen(),
          settings,
        );

      // Budget routes
      case AppRoutes.budgetList:
        return _createRoute(const budget_screen.BudgetListScreen(), settings);

      // Budget Plan routes
      case AppRoutes.budgetPlansList:
        return _createRoute(
          const budget_plan_screen.BudgetPlansListScreen(),
          settings,
        );

      case AppRoutes.createBudgetPlan:
        return _createRoute(
          const create_budget_plan_screen.CreateBudgetPlanScreen(),
          settings,
        );

      case AppRoutes.budgetPlanDetail:
        final args = settings.arguments as String;
        return _createRoute(
          budget_plan_detail_screen.BudgetPlanDetailScreen(planUuid: args),
          settings,
        );

      case AppRoutes.editBudgetPlan:
        final args = settings.arguments as String;
        return _createRoute(
          create_budget_plan_screen.EditBudgetPlanScreen(planUuid: args),
          settings,
        );

      // Savings routes
      case AppRoutes.savings:
        return _createRoute(const savings_screen.SavingsScreen(), settings);

      // Money Storage routes
      case AppRoutes.moneyStorage:
        return _createRoute(
          const money_storage_screen.MoneyStorageScreen(),
          settings,
        );

      // Reports routes
      case AppRoutes.reports:
      case AppRoutes.analytics:
        return _createRoute(const reports_screen.ReportsScreen(), settings);

      // Settings routes
      case AppRoutes.settings:
        return _createRoute(const SettingsScreenWrapper(), settings);

      // Profile routes
      case AppRoutes.profile:
        return _createRoute(const ProfileScreen(), settings);

      // Backup & Restore routes
      case AppRoutes.backupRestore:
        return _createRoute(const BackupRestoreScreen(), settings);

      // Notifications routes
      case AppRoutes.notifications:
        return _createRoute(
          const notifications_screen.NotificationsScreen(),
          settings,
        );

      // Commitments routes
      case AppRoutes.commitment:
        return _createRoute(const CommitmentScreen(), settings);

      // Commitments routes
      case AppRoutes.categoryManage:
        return _createRoute(const CategoryManagementScreen(), settings);

      // Commitment Task routes
      case AppRoutes.commitmentTask:
        return _createRoute(
          commitment_task_screen.CommitmentTaskScreen(
            bloc: CommitmentTaskBloc(CommitmentTaskRepository()),
          ),
          settings,
        );

      // Payee Management routes
      case AppRoutes.payeeManagement:
        return _createRoute(
          payee_management_screen.PayeeManagementScreen(),
          settings,
        );

      // Developer/Debug routes
      case AppRoutes.hiddenUtilityMenu:
        return _createRoute(const HiddenUtilityMenuScreen(), settings);

      case AppRoutes.logViewer:
        return _createRoute(const LogViewerScreen(), settings);

      case AppRoutes.logSettings:
        return _createRoute(const LogSettingsScreen(), settings);

      // Default: Show error screen
      default:
        return _createRoute(
          _ErrorScreen(message: 'No route defined for ${settings.name}'),
          settings,
        );
    }
  }

  /// Create a material page route with proper transitions
  static MaterialPageRoute _createRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(settings: settings, builder: (context) => widget);
  }

  /// Navigate to a named route with typed arguments
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    RouteArguments? arguments,
  }) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    RouteArguments? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  /// Navigate and clear all previous routes
  static void navigateAndClearStack(
    BuildContext context,
    String routeName, {
    RouteArguments? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop the current route
  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }
}

/// Error screen for undefined routes
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
