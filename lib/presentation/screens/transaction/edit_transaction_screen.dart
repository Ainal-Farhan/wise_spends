import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/repositories/category_repository.dart';
import 'package:wise_spends/presentation/blocs/category/category_bloc.dart';
import 'package:wise_spends/presentation/blocs/category/category_event.dart';
import 'package:wise_spends/presentation/blocs/category/category_state.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/presentation/blocs/transaction_form/transaction_form_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction_form/transaction_form_event.dart';
import 'package:wise_spends/presentation/screens/transaction/add_transaction_screen.dart'
    as add_screen;
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

/// Edit Transaction Screen Wrapper
/// Loads existing transaction data and initializes the form for editing
class EditTransactionScreen extends StatelessWidget {
  final String transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionBloc(
        context.read<ITransactionRepository>(),
        context.read<ISavingRepository>(),
      )..add(LoadTransactionByIdEvent(transactionId)),
      child: _EditTransactionScreenContent(transactionId: transactionId),
    );
  }
}

class _EditTransactionScreenContent extends StatelessWidget {
  final String transactionId;

  const _EditTransactionScreenContent({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Transaction')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is TransactionLoadedById) {
          final transaction = state.transaction;

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<TransactionBloc>()),
              BlocProvider(
                create: (ctx) =>
                    CategoryBloc(ctx.read<ICategoryRepository>())
                      ..add(LoadCategoriesEvent()),
              ),
              BlocProvider(
                create: (ctx) =>
                    SavingsBloc(ctx.read<ISavingRepository>())
                      ..add(LoadSavingsListEvent()),
              ),
              BlocProvider(
                create: (_) => TransactionFormBloc()
                  ..add(
                    InitializeTransactionFormForEdit(
                      transaction: transaction,
                      category: _findCategory(context, transaction.categoryId),
                    ),
                  ),
              ),
            ],
            child: add_screen.AddTransactionScreen(
              args: add_screen.AddTransactionScreenArgs(
                editingTransactionId: transactionId,
                preselectedType: transaction.type,
              ),
            ),
          );
        } else if (state is TransactionError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Transaction')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton.primary(
                    label: 'Go Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Transaction')),
          body: const Center(child: Text('Transaction not found')),
        );
      },
    );
  }

  CategoryEntity? _findCategory(BuildContext context, String categoryId) {
    try {
      final categoryBloc = context.read<CategoryBloc>();
      final state = categoryBloc.state;
      if (state is CategoryLoaded) {
        return state.categories.cast<CategoryEntity?>().firstWhere(
          (c) => c?.id == categoryId,
          orElse: () => null,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
