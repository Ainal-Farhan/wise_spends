import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');

class HomeCreditCardSummary extends StatefulWidget {
  const HomeCreditCardSummary({super.key});

  @override
  State<HomeCreditCardSummary> createState() => _HomeCreditCardSummaryState();
}

class _HomeCreditCardSummaryState extends State<HomeCreditCardSummary> {
  _CreditCardSummaryData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
      final cardRepo = locator.getCreditCardRepository();
      final chargeRepo = locator.getCreditCardChargeRepository();

      final cards = await cardRepo.getAllCards();
      if (cards.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      double totalDebt = 0.0;
      double totalReserved = 0.0;
      int cardCount = cards.length;

      // find card with highest utilisation for highlight
      CrdCardCreditCard? mostUsedCard;
      double mostUsedDebt = 0.0;

      for (final card in cards) {
        final debt = await cardRepo.getTotalDebt(card.id);
        totalDebt += debt;

        // sum reserved amounts from charges with reservedSavingId
        final charges = await chargeRepo.getChargesForCard(card.id);
        for (final charge in charges) {
          if (charge.reservedSavingId != null) {
            final unpaid = await chargeRepo.getUnpaidAmount(charge.id);
            totalReserved += unpaid;
          }
        }

        if (debt > mostUsedDebt) {
          mostUsedDebt = debt;
          mostUsedCard = card;
        }
      }

      if (mounted) {
        setState(() {
          _data = _CreditCardSummaryData(
            cardCount: cardCount,
            totalDebt: totalDebt,
            totalReserved: totalReserved,
            mostUsedCard: mostUsedCard,
            mostUsedDebt: mostUsedDebt,
          );
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _data;
    if (data == null || data.cardCount == 0) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.creditCards),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── title row ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.credit_card_rounded,
                      size: 20,
                      color: cs.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'home.credit_cards_title'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: cs.onSurfaceVariant, size: 18),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // ── stats row ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryChip(
                    label: 'home.credit_cards_count'.tr,
                    value: '${data.cardCount}',
                    valueColor: cs.secondary,
                  ),
                  _SummaryChip(
                    label: 'home.credit_cards_total_debt'.tr,
                    value: _currFmt.format(data.totalDebt),
                    valueColor: data.totalDebt > 0 ? cs.error : cs.primary,
                  ),
                  _SummaryChip(
                    label: 'home.credit_cards_reserved'.tr,
                    value: _currFmt.format(data.totalReserved),
                    valueColor: cs.primary,
                  ),
                ],
              ),
              // ── most-used card highlight ────────────────────────────────────
              if (data.mostUsedCard != null && data.mostUsedDebt > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                _UtilisationBar(
                  card: data.mostUsedCard!,
                  debt: data.mostUsedDebt,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UtilisationBar extends StatelessWidget {
  final CrdCardCreditCard card;
  final double debt;

  const _UtilisationBar({required this.card, required this.debt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = card.creditLimit > 0
        ? (debt / card.creditLimit).clamp(0.0, 1.0)
        : 0.0;
    final color = pct > 0.8 ? cs.error : pct > 0.5 ? Colors.orange : cs.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              card.name,
              style: AppTextStyles.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: cs.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _CreditCardSummaryData {
  final int cardCount;
  final double totalDebt;
  final double totalReserved;
  final CrdCardCreditCard? mostUsedCard;
  final double mostUsedDebt;

  const _CreditCardSummaryData({
    required this.cardCount,
    required this.totalDebt,
    required this.totalReserved,
    required this.mostUsedCard,
    required this.mostUsedDebt,
  });
}
