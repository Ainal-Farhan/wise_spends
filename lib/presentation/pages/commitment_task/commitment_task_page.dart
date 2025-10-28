import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/commitment_task/commitment_task_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/th_logged_in_main_template.dart';

class CommitmentTaskPage extends StatelessWidget {
  const CommitmentTaskPage({super.key});

  static const String routeName = AppRouter.commitmentTaskPageRoute;

  @override
  Widget build(BuildContext context) {
    return ThLoggedInMainTemplate(
      pageRoute: routeName,
      screen: const CommitmentTaskScreen(),
      bloc: null, // Standard BLoC doesn't require passing the bloc here
      floatingActionButtons: const [],
      showBottomNavBar: true,
    );
  }
}
