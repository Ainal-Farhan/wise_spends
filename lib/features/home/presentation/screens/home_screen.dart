import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/features/home/presentation/screens/widgets/add_transaction_sheet.dart';
import 'package:wise_spends/features/home/presentation/screens/widgets/home_app_bar.dart';
import 'package:wise_spends/features/home/presentation/screens/widgets/home_balance_section.dart';
import 'package:wise_spends/features/home/presentation/screens/widgets/home_quick_actions.dart';
import 'package:wise_spends/features/home/presentation/screens/widgets/home_transaction_section.dart';
import 'package:wise_spends/features/saving/data/repositories/i_saving_repository.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart';
import 'package:wise_spends/features/commitment/data/repositories/impl/commitment_task_repository.dart';
import 'package:wise_spends/presentation/blocs/navigation/navigation_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(
          create: (context) => TransactionBloc(
            context.read<ITransactionRepository>(),
            context.read<ISavingRepository>(),
          )..add(LoadRecentTransactionsEvent(limit: 10)),
        ),
      ],
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  int _pendingTaskCount = 0;
  StreamSubscription? _taskStreamSubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = CommitmentTaskRepository();

  @override
  void initState() {
    super.initState();
    _subscribeToTaskStream();
    _setupNavigationListener();
  }

  /// Subscribes to the live stream from Drift so any insert/update/delete
  /// on the commitment task table immediately updates the badge count —
  /// no manual refresh needed.
  void _subscribeToTaskStream() {
    _taskStreamSubscription = _repository
        .watchAll(false) // false = pending (not done) tasks
        .listen(
          (tasks) {
            if (mounted) {
              setState(() => _pendingTaskCount = tasks.length);
            }
          },
          onError: (_) {
            // Silently swallow errors; badge stays at last known value
          },
        );
  }

  void _setupNavigationListener() {
    context.read<NavigationBloc>().stream.listen((state) {
      if (state is DashboardRefreshRequested || state is NavigationNavigating) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.read<TransactionBloc>().add(RefreshTransactionsEvent());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _taskStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: NavigationSidebar(
        onNavigate: () {
          context.read<TransactionBloc>().add(RefreshTransactionsEvent());
        },
      ),
      body: BlocListener<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state is NavigationNavigating) {
            _scaffoldKey.currentState?.closeDrawer();
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(RefreshTransactionsEvent());
          },
          child: CustomScrollView(
            slivers: [
              HomeAppBar(
                pendingTaskCount: _pendingTaskCount,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BalanceOverview(),
                      const SizedBox(height: AppSpacing.xxl),
                      const HomeQuickActions(),
                      const SizedBox(height: AppSpacing.xxl),
                      HomeTransactionSection(
                        onAddTransaction: () =>
                            showAddTransactionSheet(context),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _HomeFAB(
        onPressed: () => showAddTransactionSheet(context),
      ),
    );
  }
}

/// Reads from [TransactionBloc] and renders [HomeBalanceSection]
/// or its shimmer placeholder depending on state.
class _BalanceOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded || state is RecentTransactionsLoaded) {
          final totalIncome = state is TransactionLoaded
              ? state.totalIncome
              : (state as RecentTransactionsLoaded).totalIncome;
          final totalExpenses = state is TransactionLoaded
              ? state.totalExpenses
              : (state as RecentTransactionsLoaded).totalExpenses;

          return HomeBalanceSection(
            totalBalance: totalIncome - totalExpenses,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
          );
        }
        return const HomeBalanceSectionShimmer();
      },
    );
  }
}

class _HomeFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _HomeFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      elevation: AppElevation.sm,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Add',
        style: AppTextStyles.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.primary,
    );
  }
}
