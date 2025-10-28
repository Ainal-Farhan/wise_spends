import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/money_storage/money_storage_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/th_logged_in_main_template.dart';

class MoneyStoragePage extends StatelessWidget {
  const MoneyStoragePage({super.key});

  static const String routeName = AppRouter.viewListMoneyStoragePageRoute;

  @override
  Widget build(BuildContext context) {
    return ThLoggedInMainTemplate(
      pageRoute: routeName,
      screen: const MoneyStorageScreen(),
      bloc: null, // Standard BLoC doesn't require passing the bloc here
      floatingActionButtons: const [],
      showBottomNavBar: true,
    );
  }
}
