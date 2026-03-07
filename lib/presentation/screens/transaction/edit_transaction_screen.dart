import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/data/repositories/category/i_category_repository.dart';
import 'package:wise_spends/presentation/blocs/category/category_bloc.dart';
import 'package:wise_spends/presentation/blocs/category/category_event.dart';
import 'package:wise_spends/presentation/blocs/category/category_state.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/presentation/screens/transaction/add_transaction_screen.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

class EditTransactionScreen extends StatelessWidget {
  final String transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => TransactionBloc(
            ctx.read<ITransactionRepository>(),
            ctx.read<ISavingRepository>(),
          )..add(LoadTransactionByIdEvent(transactionId)),
        ),
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
      ],
      child: _EditTransactionBody(transactionId: transactionId),
    );
  }
}

// ---------------------------------------------------------------------------
// Body — waits for transaction + categories before building the form
// ---------------------------------------------------------------------------

class _EditTransactionBody extends StatelessWidget {
  final String transactionId;

  const _EditTransactionBody({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        if (txState is TransactionLoading || txState is TransactionInitial) {
          return _loadingScaffold();
        }
        if (txState is TransactionError) {
          return _errorScaffold(context, txState.message);
        }
        if (txState is TransactionLoadedById) {
          final transaction = txState.transaction;
          final commitmentTaskVO = txState.commitmentTaskVO;
          final payeeVO = txState.payeeVO;

          return BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, catState) {
              if (catState is! CategoryLoaded) {
                return _loadingScaffold();
              }

              final CategoryEntity? category = catState.categories
                  .cast<CategoryEntity?>()
                  .firstWhere(
                    (c) => c?.id == transaction.categoryId,
                    orElse: () => null,
                  );

              final TimeOfDay? storedTime =
                  transaction.date.hour == 0 && transaction.date.minute == 0
                  ? null
                  : TimeOfDay(
                      hour: transaction.date.hour,
                      minute: transaction.date.minute,
                    );

              //
              return AddTransactionScreen(
                args: AddTransactionScreenArgs(
                  editingTransactionId: transactionId,
                  preselectedType: transaction.type,
                  existingPayee: payeeVO,
                  existingTransaction: transaction,
                  existingCommitmentTaskVO: commitmentTaskVO,
                  existingCategory: category,
                  existingTime: storedTime,
                ),
              );
            },
          );
        }
        return _loadingScaffold();
      },
    );
  }

  Scaffold _loadingScaffold() => Scaffold(
    appBar: AppBar(title: const Text('Edit Transaction')),
    body: const Center(child: CircularProgressIndicator()),
  );

  Scaffold _errorScaffold(BuildContext context, String message) => Scaffold(
    appBar: AppBar(title: const Text('Edit Transaction')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: 'Go Back',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}
