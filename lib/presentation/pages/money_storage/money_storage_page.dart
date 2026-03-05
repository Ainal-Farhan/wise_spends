import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/money_storage/money_storage_screen.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/shared/theme/widgets/components/templates/th_logged_in_main_template.dart';

class MoneyStoragePage extends StatelessWidget {
  const MoneyStoragePage({super.key});

  static const String routeName = AppRoutes.moneyStorage;

  @override
  Widget build(BuildContext context) {
    return ThLoggedInMainTemplate(
      pageRoute: routeName,
      screen: const MoneyStorageScreen(),
      bloc: null,
      showBottomNavBar: true,
    );
  }
}
