// transaction_form_widgets.dart
// Extracted widgets for transaction form screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_bloc.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_state.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_bloc.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_state.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_state.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/components/forms/form_locked_fields.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Account section (add mode)
// ─────────────────────────────────────────────────────────────────────────────

class TransactionAccountSection extends StatelessWidget {
  final TransactionFormReady formState;

  const TransactionAccountSection({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        final savingsList = state is SavingsListLoaded
            ? state.savingsList
            : <ListSavingVO>[];

        // Convert to FormAccountItem
        final accounts = savingsList.map((s) => s.toFormAccountItem()).toList();

        if (formState.transactionType == TransactionType.transfer) {
          final sourceAccount = accounts.cast<FormAccountItem?>().firstWhere(
            (a) => a?.id == formState.selectedSourceAccount,
            orElse: () => null,
          );
          final destinationAccount = accounts
              .cast<FormAccountItem?>()
              .firstWhere(
                (a) => a?.id == formState.selectedDestinationAccount,
                orElse: () => null,
              );

          return FormTransferAccountSelector(
            sourceAccount: sourceAccount,
            destinationAccount: destinationAccount,
            accounts: accounts,
            onSourceChanged: (v) => context.read<TransactionFormBloc>().add(
              SelectSourceAccount(v?.id),
            ),
            onDestinationChanged: (v) => context
                .read<TransactionFormBloc>()
                .add(SelectDestinationAccount(v?.id)),
          );
        }

        final selectedAccount = accounts.cast<FormAccountItem?>().firstWhere(
          (a) => a?.id == formState.selectedSourceAccount,
          orElse: () => null,
        );

        final isIncome = formState.transactionType == TransactionType.income;
        return FormAccountSelector(
          selectedAccount: selectedAccount,
          accounts: accounts,
          label: isIncome
              ? 'transaction.account.received_into'.tr
              : 'transaction.account.paid_from'.tr,
          hint: isIncome
              ? 'transaction.account.received_hint'.tr
              : 'transaction.account.paid_hint'.tr,
          onAccountSelected: (v) => context.read<TransactionFormBloc>().add(
            SelectSourceAccount(v?.id),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locked account section (edit mode)
// ─────────────────────────────────────────────────────────────────────────────

class TransactionLockedAccountSection extends StatelessWidget {
  final TransactionFormReady formState;

  const TransactionLockedAccountSection({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        final list = state is SavingsListLoaded
            ? state.savingsList
            : <ListSavingVO>[];

        String nameFor(String? id) =>
            list
                .cast<ListSavingVO?>()
                .firstWhere((s) => s?.saving.id == id, orElse: () => null)
                ?.saving
                .name ??
            id ??
            'transaction.account.unknown'.tr;

        final isTransfer =
            formState.transactionType == TransactionType.transfer ||
            (formState.transactionType == TransactionType.commitment &&
                formState.selectedDestinationAccount != null);

        if (isTransfer) {
          return LockedField(
            label: 'transaction.field.transfer_accounts'.tr,
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AccountChip(
                  name: nameFor(formState.selectedSourceAccount),
                  icon: TransactionType.expense.icon,
                  color: TransactionType.expense.color,
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                AccountChip(
                  name: nameFor(formState.selectedDestinationAccount),
                  icon: TransactionType.income.icon,
                  color: TransactionType.income.color,
                ),
              ],
            ),
          );
        }

        final isIncome = formState.transactionType == TransactionType.income;
        return LockedAccountDisplay(
          account: _findAccountById(list, formState.selectedSourceAccount),
          label: isIncome
              ? 'transaction.field.received_into'.tr
              : 'transaction.field.paid_from'.tr,
        );
      },
    );
  }

  FormAccountItem? _findAccountById(
    List<ListSavingVO> list,
    String? accountId,
  ) {
    final account = list.cast<ListSavingVO?>().firstWhere(
      (s) => s?.saving.id == accountId,
      orElse: () => null,
    );
    return account?.toFormAccountItem();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category picker (add mode)
// ─────────────────────────────────────────────────────────────────────────────

class TransactionCategoryPicker extends StatelessWidget {
  final TransactionFormReady formState;

  const TransactionCategoryPicker({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = state.categories
            .where((c) {
              return formState.transactionType == TransactionType.income
                  ? c.isIncome
                  : c.isExpense;
            })
            .map((c) => c.toFormCategoryItem())
            .toList();

        if (categories.isEmpty) {
          return const TransactionEmptyCategoriesHint();
        }

        return FormCategoryPicker(
          selectedCategory: formState.selectedCategory?.toFormCategoryItem(),
          categories: categories,
          typeColor: formState.transactionType.color,
          label: 'transaction.add.category'.tr,
          onCategorySelected: (category) {
            final domainCategory = state.categories.firstWhere(
              (c) => c.id == category?.id,
              orElse: () => categories.first as CategoryEntity,
            );
            context.read<TransactionFormBloc>().add(
              SelectCategory(domainCategory),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payee picker (add mode)
// ─────────────────────────────────────────────────────────────────────────────

class TransactionPayeePicker extends StatelessWidget {
  final TransactionFormReady formState;

  const TransactionPayeePicker({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayeeBloc, PayeeState>(
      builder: (context, state) {
        final payees = state is PayeesLoaded
            ? state.payees.map((p) => p.toFormPayeeItem()).toList()
            : <FormPayeeItem>[];

        return FormPayeePicker(
          selectedPayee: formState.selectedPayee?.toFormPayeeItem(),
          payees: payees,
          label: 'transaction.add.payee'.tr,
          showOptionalLabel: true,
          onPayeeSelected: (payee) {
            if (payee == null) {
              context.read<TransactionFormBloc>().add(const SelectPayee(null));
            } else if (state is PayeesLoaded) {
              final domainPayee = state.payees.firstWhere(
                (p) => p.id == payee.id,
                orElse: () => state.payees.first,
              );
              context.read<TransactionFormBloc>().add(SelectPayee(domainPayee));
            }
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Note field with toggle
// ─────────────────────────────────────────────────────────────────────────────

class TransactionNoteSection extends StatefulWidget {
  final TransactionFormReady formState;
  final TextEditingController controller;

  const TransactionNoteSection({
    super.key,
    required this.formState,
    required this.controller,
  });

  @override
  State<TransactionNoteSection> createState() => _TransactionNoteSectionState();
}

class _TransactionNoteSectionState extends State<TransactionNoteSection> {
  @override
  Widget build(BuildContext context) {
    if (!widget.formState.showNoteField) {
      return TextButton.icon(
        onPressed: () => widget.controller.clear(),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text('transaction.add.add_note'.tr),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    return AppTextField(
      label: 'transaction.add.note'.tr,
      hint: 'transaction.add.note_hint'.tr,
      controller: widget.controller,
      prefixIcon: Icons.note_alt_outlined,
      maxLines: 3,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit button
// ─────────────────────────────────────────────────────────────────────────────

class TransactionSubmitButton extends StatelessWidget {
  final TransactionFormReady formState;
  final bool isEditMode;
  final VoidCallback? onPressed;

  const TransactionSubmitButton({
    super.key,
    required this.formState,
    required this.isEditMode,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionLoading;
        final label = isEditMode
            ? (isLoading ? 'transaction.updating'.tr : 'transaction.update'.tr)
            : (isLoading ? 'transaction.saving'.tr : 'transaction.save'.tr);

        return AppButton.primary(
          label: label,
          isLoading: isLoading,
          isFullWidth: true,
          onPressed: isLoading ? null : onPressed,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty categories hint
// ─────────────────────────────────────────────────────────────────────────────

class TransactionEmptyCategoriesHint extends StatelessWidget {
  const TransactionEmptyCategoriesHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'transaction.category.empty_hint'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
