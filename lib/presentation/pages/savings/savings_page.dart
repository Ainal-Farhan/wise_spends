import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/savings/savings_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/shared/theme/widgets/components/templates/th_logged_in_main_template.dart';

class SavingsPage extends StatelessWidget {
  const SavingsPage({super.key});

  static const String routeName = AppRouter.savingsPageRoute;

  @override
  Widget build(BuildContext context) {
    return ThLoggedInMainTemplate(
      pageRoute: routeName,
      screen: const SavingsScreen(),
      bloc: null,
      showBottomNavBar: true,
    );
  }
}
