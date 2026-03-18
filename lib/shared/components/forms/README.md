# Shared Form Components Architecture

## Overview

This directory contains reusable form components that provide a consistent UI/UX across all forms in the WiseSpends application. The components are designed to be generic and can be used in any screen that requires form input.

## Features

- ✅ **WiseLogger Integration**: All user interactions are logged for debugging and audit trails
- ✅ **Full Localization**: All text uses the i18n localization system
- ✅ **Consistent UI**: Standardized look and feel across all forms
- ✅ **Type-Safe**: Strongly typed models and callbacks
- ✅ **Accessible**: Built-in focus management and labels

## Location

```
lib/shared/components/forms/
```

## Available Components

### 1. **FormAmountField**
Amount input field with quick amount suggestions.

**Features:**
- Animated focus states
- Quick amount chips for fast input
- Customizable currency symbol
- Type-based color theming (expense/income/transfer)
- Auto-resizing text based on amount length

**Usage:**
```dart
FormAmountField(
  controller: _amountController,
  fieldType: FormAmountFieldType.expense,
  label: 'Amount',
  currencySymbol: 'RM',
  onChanged: (value) => print('Amount: $value'),
)
```

### 2. **FormCategoryPicker**
Category selection with search and grid display.

**Features:**
- Searchable category list
- Grid layout with icons
- Selected state indication
- Type-based color theming
- Empty state handling

**Usage:**
```dart
FormCategoryPicker(
  selectedCategory: _selectedCategory,
  categories: categories,
  typeColor: AppColors.error,
  label: 'Category',
  onCategorySelected: (category) {
    setState(() => _selectedCategory = category);
  },
)
```

### 3. **FormPayeePicker**
Payee selection with dropdown and selected state chip.

**Features:**
- Shows selected payee as removable chip
- Dropdown for selection
- Supports bank name and account number display
- Optional field indicator
- Empty state handling

**Usage:**
```dart
FormPayeePicker(
  selectedPayee: _selectedPayee,
  payees: payees,
  label: 'Payee',
  showOptionalLabel: true,
  onPayeeSelected: (payee) {
    setState(() => _selectedPayee = payee);
  },
)
```

### 4. **FormDateTimePicker**
Date and time picker with bottom sheet interface.

**Features:**
- Combined date and time selection
- Relative date display (Today, Yesterday)
- Optional time selection
- Clear time option
- Action buttons in sheet

**Usage:**
```dart
FormDateTimePicker(
  selectedDate: _selectedDate,
  selectedTime: _selectedTime,
  label: 'Date & Time',
  onDateChanged: (date) {
    setState(() => _selectedDate = date);
  },
  onTimeChanged: (time) {
    setState(() => _selectedTime = time);
  },
  onTimeCleared: () {
    setState(() => _selectedTime = null);
  },
)
```

### 5. **FormAccountSelector**
Account/savings selection with balance display.

**Features:**
- Account type icons (cash, bank, credit card, e-wallet)
- Balance display
- Exclude account option (for transfers)
- Visual selection feedback

**Usage:**
```dart
FormAccountSelector(
  selectedAccount: _selectedAccount,
  accounts: accounts,
  excludeId: _destinationAccount?.id,
  label: 'Account',
  onAccountSelected: (account) {
    setState(() => _selectedAccount = account);
  },
)
```

### 6. **FormTransferAccountSelector**
Source and destination account selector for transfers.

**Features:**
- Two linked account selectors
- Visual arrow indicator
- Automatic exclusion logic
- Type-based theming

**Usage:**
```dart
FormTransferAccountSelector(
  sourceAccount: _sourceAccount,
  destinationAccount: _destinationAccount,
  accounts: accounts,
  label: 'Transfer Between Accounts',
  onSourceChanged: (account) {
    setState(() => _sourceAccount = account);
  },
  onDestinationChanged: (account) {
    setState(() => _destinationAccount = account);
  },
)
```

### 7. **FormTypeToggle**
Transaction type toggle (Expense/Income/Transfer).

**Features:**
- Three-state toggle
- Icon and label for each type
- Animated selection
- Type-specific colors

**Usage:**
```dart
FormTypeToggle(
  selectedType: _selectedType,
  onTypeSelected: (type) {
    setState(() => _selectedType = type);
  },
)
```

### 8. **Locked Field Components (Edit Mode)**

Display-only variants for edit mode where certain fields cannot be changed.

**Components:**
- `LockedTypeDisplay` - Shows transaction type
- `LockedAmountDisplay` - Shows amount
- `LockedCategoryDisplay` - Shows category
- `LockedPayeeDisplay` - Shows payee
- `LockedAccountDisplay` - Shows account
- `LockedDateTimeDisplay` - Shows date/time
- `EditModeBanner` - Banner indicating edit mode

**Usage:**
```dart
LockedAmountDisplay(
  amount: '150.00',
  transactionType: FormTransactionType.expense,
  label: 'Amount',
)
```

## Data Models

### FormTransactionType
```dart
enum FormTransactionType {
  expense(label: 'Expense', icon: Icons.trending_down, color: AppColors.error),
  income(label: 'Income', icon: Icons.trending_up, color: AppColors.success),
  transfer(label: 'Transfer', icon: Icons.swap_horiz, color: AppColors.primary),
}
```

### FormAmountFieldType
```dart
enum FormAmountFieldType {
  expense(color: AppColors.error, quickAmounts: [10, 50, 100, 500]),
  income(color: AppColors.success, quickAmounts: [500, 1000, 2000, 5000]),
  transfer(color: AppColors.primary, quickAmounts: [100, 500, 1000, 2000]),
}
```

### FormCategoryItem
```dart
class FormCategoryItem {
  final String id;
  final String name;
  final int iconCodePoint;
  final bool isEnabled;
}
```

### FormPayeeItem
```dart
class FormPayeeItem {
  final String id;
  final String? name;
  final String? bankName;
  final String? accountNumber;
}
```

### FormAccountItem
```dart
class FormAccountItem {
  final String id;
  final String name;
  final String type; // cash, bank, credit_card, ewallet, savings
  final double balance;
  final String? currencySymbol;
}
```

## Integration with Domain Entities

To use your domain-specific entities with the shared form components, create adapter extensions:

```dart
// Example: lib/features/transaction/presentation/adapters/transaction_form_adapters.dart

extension CategoryEntityExt on CategoryEntity {
  FormCategoryItem toFormCategoryItem() {
    return FormCategoryItem(
      id: id,
      name: name,
      iconCodePoint: iconCodePoint,
      isEnabled: isActive,
    );
  }
}

extension PayeeVOExt on PayeeVO {
  FormPayeeItem toFormPayeeItem() {
    return FormPayeeItem(
      id: id,
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
    );
  }
}

extension ListSavingVOExt on ListSavingVO {
  FormAccountItem toFormAccountItem() {
    return FormAccountItem(
      id: saving.id,
      name: saving.name ?? 'Unnamed',
      type: saving.type,
      balance: saving.currentAmount,
      reserveSummary: saving.reserveSummary,
    );
  }
}
```

## Usage Pattern

### 1. Create Form Screen
```dart
class MyFormScreen extends StatefulWidget {
  @override
  State<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  // Controllers
  final _amountController = TextEditingController();
  
  // State
  FormTransactionType _type = FormTransactionType.expense;
  FormAccountItem? _account;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Transaction')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FormTypeToggle(
              selectedType: _type,
              onTypeSelected: (t) => setState(() => _type = t),
            ),
            FormAmountField(
              controller: _amountController,
              fieldType: _type.toAmountFieldType(),
            ),
            // ... other fields
          ],
        ),
      ),
    );
  }
}
```

### 2. Handle Form Submission
```dart
void _submitForm() {
  // Validate
  final amount = double.tryParse(_amountController.text);
  if (amount == null || amount <= 0) {
    showError('Please enter a valid amount');
    return;
  }
  
  if (_account == null) {
    showError('Please select an account');
    return;
  }
  
  // Process with your BLoC/Repository
  context.read<MyBloc>().add(
    CreateTransaction(
      amount: amount,
      type: _type.toTransactionType(),
      accountId: _account!.id,
      // ...
    ),
  );
}
```

### 3. Edit Mode with Locked Fields
```dart
if (isEditMode) {
  return Column(
    children: [
      const EditModeBanner(),
      LockedTypeDisplay(transactionType: _existingType),
      LockedAmountDisplay(amount: _existingAmount),
      // Only allow editing note
      AppTextField(
        label: 'Note',
        controller: _noteController,
      ),
      AppButton(
        label: 'Update',
        onPressed: _updateTransaction,
      ),
    ],
  );
}
```

## Benefits

1. **Consistency**: All forms look and behave the same
2. **Reusability**: Write once, use everywhere
3. **Maintainability**: Fix bugs or improve UI in one place
4. **Type Safety**: Strongly typed models and callbacks
5. **Accessibility**: Built-in focus management and labels
6. **Theming**: Automatic color theming based on transaction type
7. **Localization**: All text uses the i18n system

## Best Practices

1. **Always use adapters** to convert domain entities to form models
2. **Keep form state** in the screen, not in the components
3. **Use callbacks** to communicate changes back to the screen
4. **Validate on submit**, not on every field change
5. **Use locked fields** in edit mode for immutable data
6. **Show optional label** for optional fields
7. **Handle empty states** gracefully

## Examples

See `lib/features/transaction/presentation/examples/shared_form_usage_example.dart` for complete working examples.

## Migration Guide

### From Old Transaction-Specific Widgets

**Before:**
```dart
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_amount_field.dart';

TransactionAmountField(
  controller: _controller,
  transactionType: TransactionType.expense,
  typeColor: AppColors.error,
)
```

**After:**
```dart
import 'package:wise_spends/shared/components/forms/forms.dart';

FormAmountField(
  controller: _controller,
  fieldType: FormAmountFieldType.expense,
)
```

The new components:
- Are generic and reusable
- Handle their own theming internally
- Have better separation of concerns
- Support any form, not just transactions

## Future Enhancements

- [ ] Add recurring transaction selector
- [ ] Add location picker
- [ ] Add receipt image upload
- [ ] Add split transaction UI
- [ ] Add tags/multi-category support
- [ ] Add biometric confirmation
- [ ] Add voice input for amounts
- [ ] Add currency conversion for multi-currency accounts
