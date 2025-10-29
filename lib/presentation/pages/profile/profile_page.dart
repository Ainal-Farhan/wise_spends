import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/profile/profile_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/shared/theme/widgets/components/templates/th_logged_in_main_template.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String routeName = AppRouter.profilePageRoute;

  @override
  Widget build(BuildContext context) {
    return ThLoggedInMainTemplate(
      pageRoute: routeName,
      screen: const ProfileScreen(),
      bloc: null,
      showBottomNavBar: true,
    );
  }
}
