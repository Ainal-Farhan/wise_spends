import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:wise_spends/presentation/widgets/components/transaction_card.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/router/route_arguments.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

class HomeTransactionSection extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const HomeTransactionSection({super.key, required this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'transaction.recent'.tr,
          onSeeAll: () {
            AppRouter.navigateTo(
              context,
              AppRoutes.transactionHistory,
              arguments: const TransactionHistoryArgs(),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const ShimmerTransactionList(itemCount: 5);
            } else if (state is RecentTransactionsLoaded) {
              if (state.recentTransactions.isEmpty) {
                return _EmptyTransactionState(
                  onAddTransaction: onAddTransaction,
                );
              }
              return _TransactionList(
                transactions: state.recentTransactions,
                onAddTransaction: onAddTransaction,
              );
            } else if (state is TransactionError) {
              return _ErrorState(message: state.message);
            } else if (state is TransactionEmpty) {
              return _EmptyTransactionState(onAddTransaction: onAddTransaction);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final VoidCallback onAddTransaction;

  const _TransactionList({
    required this.transactions,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCard(
          title: transaction.title,
          amount: transaction.amount,
          type: transaction.type,
          icon: _getCategoryIcon(transaction.category),
          date: transaction.date,
          note: transaction.note,
          onTap: () {
            AppRouter.navigateTo(
              context,
              AppRoutes.transactionDetail,
              arguments: TransactionDetailArgs(transaction.id),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(CategoryEntity? category) {
    if (category == null) return Icons.category_rounded;
    return CategoryIconMapper.getIconForCategory(category.iconCodePoint);
  }
}

class _EmptyTransactionState extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const _EmptyTransactionState({required this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return NoTransactionsEmptyState(onAddTransaction: onAddTransaction);
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: AppIconSize.hero,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'home.something_went_wrong'.tr,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: 'Retry',
            onPressed: () {
              context.read<TransactionBloc>().add(
                LoadRecentTransactionsEvent(),
              );
            },
          ),
        ],
      ),
    );
  }
}
