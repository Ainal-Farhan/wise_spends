import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_screen.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_event.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class CommitmentPage extends StatefulWidget {
  static const String routeName = AppRouter.commitmentPageRoute;

  const CommitmentPage({super.key});

  @override
  State<CommitmentPage> createState() => _CommitmentPageState();
}

class _CommitmentPageState extends State<CommitmentPage> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CommitmentBloc>(context);
    return IThLoggedInMainTemplate(
      pageRoute: AppRouter.commitmentPageRoute,
      screen: CommitmentScreen(
        bloc: bloc,
        initialEvent: LoadListCommitmentEvent(),
      ),
      showBottomNavBar: false,
      bloc: bloc,
    );
  }
}
