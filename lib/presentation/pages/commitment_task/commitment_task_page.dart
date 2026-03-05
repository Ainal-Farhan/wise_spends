import 'package:flutter/material.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_task_repository.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/presentation/screens/commitment_task/commitment_task_screen.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/shared/theme/widgets/components/templates/th_logged_in_main_template.dart';

class CommitmentTaskPage extends StatelessWidget {
  const CommitmentTaskPage({super.key});

  static const String routeName = AppRoutes.commitmentTask;

  @override
  Widget build(BuildContext context) {
    CommitmentTaskBloc bloc = CommitmentTaskBloc(CommitmentTaskRepository());
    return ThLoggedInMainTemplate(
      pageRoute: routeName,
      screen: CommitmentTaskScreen(bloc: bloc),
      bloc: bloc,
      showBottomNavBar: true,
    );
  }
}
