/// Route constants for WiseSpends app
/// Centralized route path definitions
library;

abstract class AppRoutes {
  // Auth routes
  static const String login = '/login';

  // Main routes
  static const String home = '/';
  static const String homeLoggedIn = '/home';

  // Transaction routes
  static const String addTransaction = '/transaction/add';
  static const String transactionDetail = '/transaction/detail';
  static const String editTransaction = '/transaction/edit';
  static const String transactionHistory = '/transaction/history';

  // Category routes
  static const String categoryList = '/category/list';
  static const String categoryManage = '/category/manage';

  // Budget routes
  static const String budgetList = '/budget/list';
  static const String budgetDetail = '/budget/detail';
  static const String createBudget = '/budget/create';
  static const String editBudget = '/budget/edit';

  // Budget Plan routes (NEW)
  static const String budgetPlansList = '/budget-plans/list';
  static const String createBudgetPlan = '/budget-plans/create';
  static const String editBudgetPlan = '/budget-plans/edit';
  static const String budgetPlanDetail = '/budget-plans/detail';

  // Reports routes
  static const String reports = '/reports';
  static const String analytics = '/analytics';

  // Settings routes
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String dataManagement = '/data';
  static const String backupRestore = '/backup-restore';

  // Other routes
  static const String savings = '/savings';
  static const String commitment = '/commitment';
  static const String commitmentTask = '/commitment_task';
  static const String payeeManagement = '/payee_management';
  static const String moneyStorage = '/money-storage';
}
