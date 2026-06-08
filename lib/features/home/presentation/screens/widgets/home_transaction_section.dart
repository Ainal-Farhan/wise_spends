import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
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

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

enum _TxFilter { all, income, expense, transfer, charge }

class HomeTransactionSection extends StatefulWidget {
  final VoidCallback onAddTransaction;

  const HomeTransactionSection({super.key, required this.onAddTransaction});

  @override
  State<HomeTransactionSection> createState() => _HomeTransactionSectionState();
}

class _HomeTransactionSectionState extends State<HomeTransactionSection> {
  _TxFilter _filter = _TxFilter.all;
  List<CrdCardCharge>? _charges;
  bool _chargesLoading = false;

  Future<void> _loadCharges() async {
    if (_chargesLoading) return;
    setState(() => _chargesLoading = true);
    try {
      final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getCreditCardChargeRepository();
      final charges = await repo.getRecentCharges(10);
      if (mounted) setState(() => _charges = charges);
    } catch (_) {
      if (mounted) setState(() => _charges = []);
    } finally {
      if (mounted) setState(() => _chargesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: _TxFilter.values.map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: FilterChip(
                  label: Text(_filterLabel(f)),
                  selected: _filter == f,
                  onSelected: (_) {
                    setState(() => _filter = f);
                    if (f == _TxFilter.charge) _loadCharges();
                  },
                  visualDensity: VisualDensity.compact,
                  selectedColor: f == _TxFilter.charge
                      ? cs.tertiaryContainer
                      : null,
                  checkmarkColor: f == _TxFilter.charge
                      ? cs.onTertiaryContainer
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        if (_filter == _TxFilter.charge)
          _ChargeList(
            charges: _charges,
            loading: _chargesLoading,
            onAddTransaction: widget.onAddTransaction,
          )
        else
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return const ShimmerTransactionList(itemCount: 5);
              } else if (state is RecentTransactionsLoaded) {
                final filtered = _applyFilter(state.recentTransactions);
                if (filtered.isEmpty) {
                  return _EmptyTransactionState(
                    onAddTransaction: widget.onAddTransaction,
                  );
                }
                return _TransactionList(
                  transactions: filtered,
                  onAddTransaction: widget.onAddTransaction,
                );
              } else if (state is TransactionError) {
                return _ErrorState(message: state.message);
              } else if (state is TransactionEmpty) {
                return _EmptyTransactionState(
                  onAddTransaction: widget.onAddTransaction,
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  String _filterLabel(_TxFilter f) => switch (f) {
    _TxFilter.all => 'All',
    _TxFilter.income => 'Income',
    _TxFilter.expense => 'Expense',
    _TxFilter.transfer => 'Transfer',
    _TxFilter.charge => 'Charge',
  };

  List<TransactionEntity> _applyFilter(List<TransactionEntity> all) {
    return switch (_filter) {
      _TxFilter.all => all,
      _TxFilter.income =>
        all.where((t) => t.type == TransactionType.income).toList(),
      _TxFilter.expense =>
        all.where((t) => t.type == TransactionType.expense).toList(),
      _TxFilter.transfer =>
        all.where((t) => t.type == TransactionType.transfer).toList(),
      _TxFilter.charge => all,
    };
  }
}

// ── Charge list ────────────────────────────────────────────────────────────────

class _ChargeList extends StatelessWidget {
  final List<CrdCardCharge>? charges;
  final bool loading;
  final VoidCallback onAddTransaction;

  const _ChargeList({
    required this.charges,
    required this.loading,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    if (loading || charges == null) {
      return const ShimmerTransactionList(itemCount: 5);
    }
    if (charges!.isEmpty) {
      return _EmptyTransactionState(onAddTransaction: onAddTransaction);
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: charges!.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final charge = charges![index];
        return _ChargeTile(charge: charge);
      },
    );
  }
}

class _ChargeTile extends StatelessWidget {
  final CrdCardCharge charge;

  const _ChargeTile({required this.charge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: charge.isRebate
                    ? cs.primary.withValues(alpha: 0.1)
                    : cs.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                charge.isRebate
                    ? Icons.card_giftcard_rounded
                    : Icons.credit_card_rounded,
                size: 20,
                color: charge.isRebate ? cs.primary : cs.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    charge.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        _dateFmt.format(charge.chargeDate),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (charge.status == 'pending') ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Pending',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${charge.isRebate ? '+' : '-'}${_currFmt.format(charge.amount)}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: charge.isRebate ? cs.primary : cs.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Transaction list ───────────────────────────────────────────────────────────

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
          icon: transaction.category == null
              ? transaction.type.icon
              : _getCategoryIcon(transaction.category),
          date: transaction.date,
          note: transaction.note,
          isRevoked: transaction.isRevoked,
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
