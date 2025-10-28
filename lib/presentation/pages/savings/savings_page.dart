import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/data/repositories/savings_repository.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_event.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_state.dart';
import 'package:wise_spends/presentation/screens/savings/savings_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/th_logged_in_main_template.dart';

class SavingsPage extends StatelessWidget {
  const SavingsPage({super.key});

  static const String routeName = AppRouter.savingsPageRoute;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavingsBloc(
        SavingsRepository(),
      )..add(LoadSavingsListEvent()),
      child: BlocBuilder<SavingsBloc, SavingsState>(
        builder: (context, state) {
          List<FloatingActionButton> fabList = [];
          
          // Only show FAB if not in form state
          if (state is! SavingsFormLoaded && state is! SavingTransactionFormLoaded) {
            fabList = [
              FloatingActionButton(
                heroTag: 'savings_add_button',
                onPressed: () {
                  context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add),
              ),
            ];
          }

          return ThLoggedInMainTemplate(
            pageRoute: routeName,
            screen: const SavingsScreen(),
            bloc: null, // Standard BLoC doesn't require passing the bloc here
            floatingActionButtons: fabList,
            showBottomNavBar: true,
          );
        },
      ),
    );
  }
}
