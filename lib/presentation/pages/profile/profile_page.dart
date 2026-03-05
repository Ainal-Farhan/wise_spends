import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/profile/profile_screen.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/shared/theme/widgets/components/templates/th_logged_in_main_template.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String routeName = AppRoutes.profile;

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
