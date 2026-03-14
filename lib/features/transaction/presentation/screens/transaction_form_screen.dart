// transaction_form_screen.dart
// Unified screen for adding and editing transactions
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_event.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_bloc.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_event.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_state.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_form_widgets.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/components/forms/form_locked_fields.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

class TransactionFormScreenArgs {
  final TransactionType? preselectedType;
  final String? editingTransactionId;
  final CommitmentTaskVO? existingCommitmentTaskVO;
  final TransactionEntity? existingTransaction;
  final CategoryEntity? existingCategory;
  final PayeeVO? existingPayee;
  final TimeOfDay? existingTime;

  const TransactionFormScreenArgs({
    this.preselectedType,
    this.editingTransactionId,
    this.existingTransaction,
    this.existingCommitmentTaskVO,
    this.existingCategory,
    this.existingPayee,
    this.existingTime,
  });

  bool get isEditMode => editingTransactionId != null;
}

/// Unified transaction form screen for both add and edit modes
class TransactionFormScreen extends StatelessWidget {
  final TransactionFormScreenArgs? args;

  const TransactionFormScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => CategoryBloc(
            SingletonUtil.getSingleton<IRepositoryLocator>()!
                .getCategoryRepository(),
          )..add(LoadCategoriesEvent()),
        ),
        BlocProvider(
          create: (ctx) => TransactionBloc(
            SingletonUtil.getSingleton<IRepositoryLocator>()!
                .getTransactionRepository(),
            SingletonUtil.getSingleton<IRepositoryLocator>()!
                .getSavingRepository(),
          ),
        ),
        BlocProvider(
          create: (ctx) => SavingsBloc(
            SingletonUtil.getSingleton<IRepositoryLocator>()!
                .getSavingRepository(),
          )..add(LoadSavingsListEvent()),
        ),
        BlocProvider(
          create: (ctx) => PayeeBloc(
            SingletonUtil.getSingleton<IRepositoryLocator>()!
                .getPayeeRepository(),
          )..add(LoadPayees()),
        ),
        BlocProvider(
          create: (ctx) {
            final a = args;
            final bloc = TransactionFormBloc();
            if (a?.isEditMode ?? false) {
              bloc.add(
                InitializeTransactionFormForEdit(
                  transaction: a!.existingTransaction!,
                  category: a.existingCategory,
                  payee: a.existingPayee,
                  selectedTime: a.existingTime,
                ),
              );
            } else {
              bloc.add(
                InitializeTransactionForm(preselectedType: a?.preselectedType),
              );
            }
            return bloc;
          },
        ),
      ],
      child: _TransactionFormScreenContent(args: args),
    );
  }
}

class _TransactionFormScreenContent extends StatefulWidget {
  final TransactionFormScreenArgs? args;
  const _TransactionFormScreenContent({this.args});

  @override
  State<_TransactionFormScreenContent> createState() =>
      _TransactionFormScreenContentState();
}

class _TransactionFormScreenContentState
    extends State<_TransactionFormScreenContent> {
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  bool _controllersSynced = false;
  bool get _isEditMode => widget.args?.isEditMode ?? false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _syncControllersFromFormState(TransactionFormReady formState) {
    if (_controllersSynced) return;
    if (!_isEditMode) {
      _controllersSynced = true;
      return;
    }
    if (formState.amount != null && _amountController.text.isEmpty) {
      _amountController.text = formState.amount!;
    }
    if (formState.title != null && _titleController.text.isEmpty) {
      _titleController.text = formState.title!;
    }
    if (formState.note != null && _noteController.text.isEmpty) {
      _noteController.text = formState.note!;
    }
    _controllersSynced = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'transaction.edit'.tr : 'transaction.add'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionCreated || state is TransactionUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      state is TransactionUpdated
                          ? 'transaction.updated_success'.tr
                          : 'transaction.created_success'.tr,
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeLoggedIn,
              (r) => false,
            );
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: BlocBuilder<TransactionFormBloc, TransactionFormState>(
              builder: (context, formState) {
                if (formState is! TransactionFormReady) {
                  return const Center(child: CircularProgressIndicator());
                }
                _syncControllersFromFormState(formState);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Edit mode banner ──────────────────────────────────
                    if (_isEditMode) ...[
                      const EditModeBanner(),
                      const SizedBox(height: 16),
                    ],

                    // ── Transaction type ──────────────────────────────────
                    if (_isEditMode)
                      LockedTypeDisplay(
                        transactionType: formState.transactionType
                            .toFormTransactionType(),
                        label: 'transaction.field.type'.tr,
                      )
                    else
                      FormTypeToggle(
                        selectedType: formState.transactionType
                            .toFormTransactionType(),
                        onTypeSelected: (t) => context
                            .read<TransactionFormBloc>()
                            .add(ChangeTransactionType(t.toTransactionType())),
                      ),
                    const SizedBox(height: 20),

                    // ── Amount ────────────────────────────────────────────
                    if (_isEditMode)
                      LockedAmountDisplay(
                        amount: formState.amount ?? '0.00',
                        transactionType: formState.transactionType
                            .toFormTransactionType(),
                        label: 'transaction.field.amount'.tr,
                      )
                    else
                      FormAmountField(
                        controller: _amountController,
                        fieldType: formState.transactionType
                            .toFormAmountFieldType(),
                      ),
                    const SizedBox(height: 20),

                    // ── Account ───────────────────────────────────────────
                    if (_isEditMode)
                      TransactionLockedAccountSection(formState: formState)
                    else
                      TransactionAccountSection(formState: formState),
                    const SizedBox(height: 16),

                    // ── Description ───────────────────────────────────────
                    AppTextField(
                      label: 'transaction.add.description'.tr,
                      hint: 'transaction.add.description_hint'.tr,
                      controller: _titleController,
                      prefixIcon: Icons.description_outlined,
                    ),
                    const SizedBox(height: 16),

                    // ── Category ──────────────────────────────────────────
                    if (formState.transactionType != TransactionType.transfer &&
                        formState.transactionType !=
                            TransactionType.commitment) ...[
                      if (_isEditMode)
                        LockedCategoryDisplay(
                          category: formState.selectedCategory
                              ?.toFormCategoryItem(),
                          label: 'transaction.field.category'.tr,
                        )
                      else
                        TransactionCategoryPicker(formState: formState),
                      const SizedBox(height: 16),
                    ],

                    // ── Payee ─────────────────────────────────────────────
                    if (formState.supportsPayee) ...[
                      if (_isEditMode)
                        LockedPayeeDisplay(
                          payee: formState.selectedPayee?.toFormPayeeItem(),
                          label: 'transaction.field.payee'.tr,
                        )
                      else
                        TransactionPayeePicker(formState: formState),
                      const SizedBox(height: 16),
                    ],

                    FormDateTimePicker(
                      selectedDate: formState.selectedDate,
                      selectedTime: formState.selectedTime,
                      label: 'transaction.add.date_time'.tr,
                      onDateChanged: (d) => context
                          .read<TransactionFormBloc>()
                          .add(ChangeTransactionDate(d)),
                      onTimeChanged: (t) => context
                          .read<TransactionFormBloc>()
                          .add(ChangeTransactionTime(t)),
                      onTimeCleared: () => context
                          .read<TransactionFormBloc>()
                          .add(const ClearTransactionTime()),
                    ),
                    const SizedBox(height: 16),

                    // ── Note ──────────────────────────────────────────────
                    TransactionNoteSection(
                      formState: formState,
                      controller: _noteController,
                    ),
                    const SizedBox(height: 28),

                    // ── Submit ────────────────────────────────────────────
                    TransactionSubmitButton(
                      formState: formState,
                      isEditMode: _isEditMode,
                      onPressed: () => _submit(context, formState),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Submit handler
  // ──────────────────────────────────────────────────────────────────────────

  void _submit(BuildContext context, TransactionFormReady formState) {
    final titleText = _titleController.text.trim();
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    if (titleText.isEmpty) {
      _showError(context, 'transaction.error.description_required'.tr);
      return;
    }

    DateTime transactionDateTime = formState.selectedDate;
    if (formState.selectedTime != null) {
      transactionDateTime = DateTime(
        formState.selectedDate.year,
        formState.selectedDate.month,
        formState.selectedDate.day,
        formState.selectedTime!.hour,
        formState.selectedTime!.minute,
      );
    }

    if (_isEditMode && formState.editingTransactionId != null) {
      context.read<TransactionBloc>().add(
        UpdateTransactionEvent(
          TransactionEntity(
            id: formState.editingTransactionId!,
            title: titleText,
            date: transactionDateTime,
            note: note,
            amount: 0,
            type: formState.transactionType,
            savingId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      );
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      _showError(context, 'transaction.error.amount_required'.tr);
      return;
    }
    if (formState.selectedSourceAccount == null) {
      _showError(
        context,
        formState.transactionType == TransactionType.transfer
            ? 'transaction.error.source_account_required'.tr
            : 'transaction.error.account_required'.tr,
      );
      return;
    }
    if (formState.transactionType == TransactionType.transfer &&
        formState.selectedDestinationAccount == null) {
      _showError(context, 'transaction.error.destination_account_required'.tr);
      return;
    }
    if (formState.selectedCategory == null &&
        formState.transactionType != TransactionType.transfer &&
        formState.transactionType != TransactionType.commitment) {
      _showError(context, 'transaction.error.category_required'.tr);
      return;
    }

    context.read<TransactionBloc>().add(
      CreateTransactionEvent(
        title: titleText,
        amount: amount,
        type: formState.transactionType,
        categoryId: formState.selectedCategory?.id ?? '',
        date: formState.selectedDate,
        time: formState.selectedTime,
        note: note,
        sourceAccountId: formState.selectedSourceAccount,
        destinationAccountId:
            formState.transactionType == TransactionType.transfer
            ? formState.selectedDestinationAccount
            : null,
        payeeId: formState.selectedPayee?.id,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
