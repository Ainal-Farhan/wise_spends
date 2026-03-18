// Transaction form adapters - bridge between domain entities and shared form components
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/components/forms/forms.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category adapter
// ─────────────────────────────────────────────────────────────────────────────

extension CategoryEntityExt on CategoryEntity {
  FormCategoryItem toFormCategoryItem() {
    return FormCategoryItem(
      id: id,
      name: name,
      iconCodePoint: int.tryParse(iconCodePoint),
      icon: CategoryIconMapper.getIconForCategory(name),
      isEnabled: isActive,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payee adapter
// ─────────────────────────────────────────────────────────────────────────────

extension PayeeVOExt on PayeeVO {
  FormPayeeItem toFormPayeeItem() {
    return FormPayeeItem(
      id: id ?? '',
      name: name ?? '',
      bankName: bankName,
      accountNumber: accountNumber,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account adapter
// ─────────────────────────────────────────────────────────────────────────────

extension ListSavingVOExt on ListSavingVO {
  FormAccountItem toFormAccountItem() {
    return FormAccountItem(
      id: saving.id,
      name: saving.name ?? 'transaction.account.unnamed',
      type: saving.type,
      balance: saving.currentAmount,
      reserveSummary: reserveSummary,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction type adapter
// ─────────────────────────────────────────────────────────────────────────────

extension TransactionTypeExt on TransactionType {
  FormTransactionType toFormTransactionType() {
    return switch (this) {
      TransactionType.income => FormTransactionType.income,
      TransactionType.expense => FormTransactionType.expense,
      TransactionType.transfer => FormTransactionType.transfer,
      TransactionType.commitment => FormTransactionType.expense,
      TransactionType.budgetPlanDeposit => FormTransactionType.income,
      TransactionType.budgetPlanExpense => FormTransactionType.expense,
    };
  }

  FormAmountFieldType toFormAmountFieldType() {
    return switch (this) {
      TransactionType.income => FormAmountFieldType.income,
      TransactionType.expense => FormAmountFieldType.expense,
      TransactionType.transfer => FormAmountFieldType.transfer,
      TransactionType.commitment => FormAmountFieldType.expense,
      TransactionType.budgetPlanDeposit => FormAmountFieldType.income,
      TransactionType.budgetPlanExpense => FormAmountFieldType.expense,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form type to transaction type
// ─────────────────────────────────────────────────────────────────────────────

extension FormTransactionTypeExt on FormTransactionType {
  TransactionType toTransactionType() {
    return switch (this) {
      FormTransactionType.income => TransactionType.income,
      FormTransactionType.expense => TransactionType.expense,
      FormTransactionType.transfer => TransactionType.transfer,
    };
  }
}
