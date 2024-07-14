import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_screen.dart';
import 'package:wise_spends/bloc/impl/commitment_task/event/in_load_commitment_task_event.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class CommitmentTaskPage extends StatefulWidget {
  static const String routeName = AppRouter.commitmentTaskPageRoute;

  const CommitmentTaskPage({super.key});

  @override
  State<CommitmentTaskPage> createState() => _CommitmentTaskPageState();
}

class _CommitmentTaskPageState extends State<CommitmentTaskPage> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CommitmentTaskBloc>(context);
    return IThLoggedInMainTemplate(
      pageRoute: AppRouter.commitmentTaskPageRoute,
      screen: CommitmentTaskScreen(
        bloc: bloc,
        initialEvent: InLoadCommitmentTaskEvent(),
      ),
      showBottomNavBar: false,
      bloc: bloc,
    );
  }
}
