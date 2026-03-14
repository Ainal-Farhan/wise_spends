// transaction_payee_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_bloc.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_state.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_state.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'transaction_form_widgets.dart';

class TransactionPayeePicker extends StatelessWidget {
  final TransactionFormReady formState;

  const TransactionPayeePicker({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayeeBloc, PayeeState>(
      builder: (context, state) {
        final payees = state is PayeesLoaded ? state.payees : <PayeeVO>[];
        final selectedPayee = formState.selectedPayee;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              text: 'transaction.add.payee'.tr,
              optionalSuffix: '(${'general.optional'.tr})',
            ),
            const SizedBox(height: 10),

            // Show selected payee chip
            if (selectedPayee != null) ...[
              SelectedPayeeChip(
                payee: selectedPayee,
                onClear: () => context.read<TransactionFormBloc>().add(
                  const SelectPayee(null),
                ),
              ),
            ] else if (state is PayeeLoading)
              const LinearProgressIndicator()
            else if (payees.isEmpty)
              _NoPayeesHint()
            else
              _PayeeDropdown(
                payees: payees,
                selectedPayee: selectedPayee,
                onChanged: (id) {
                  if (id == null) {
                    context.read<TransactionFormBloc>().add(
                      const SelectPayee(null),
                    );
                    return;
                  }
                  final match = payees.cast<PayeeVO?>().firstWhere(
                    (p) => p?.id == id,
                    orElse: () => null,
                  );
                  if (match != null) {
                    context.read<TransactionFormBloc>().add(SelectPayee(match));
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

class _PayeeDropdown extends StatelessWidget {
  final List<PayeeVO> payees;
  final PayeeVO? selectedPayee;
  final ValueChanged<String?> onChanged;

  const _PayeeDropdown({
    required this.payees,
    required this.selectedPayee,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: payees.any((p) => p.id == selectedPayee?.id)
            ? selectedPayee?.id
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'transaction.payee.select_hint'.tr,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: const Icon(
              Icons.person_search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        items: payees.map((p) {
          return DropdownMenuItem<String>(
            value: p.id,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name ?? 'transaction.unknown'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (p.bankName != null || p.accountNumber != null)
                  Text(
                    [
                      if (p.bankName != null) p.bankName!,
                      if (p.accountNumber != null) p.accountNumber!,
                    ].join(' · '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _NoPayeesHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline_rounded,
            color: AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'transaction.payee.no_payees'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
