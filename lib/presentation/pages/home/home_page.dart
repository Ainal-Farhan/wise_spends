import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/home/home_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/shared/theme/widgets/components/templates/th_logged_in_main_template.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = AppRouter.homeLoggedInPageRoute;

  @override
  Widget build(BuildContext context) {
    return ThLoggedInMainTemplate(
      pageRoute: routeName,
      screen: const HomeScreen(),
      bloc: null,
      showBottomNavBar: true,
    );
  }
}
