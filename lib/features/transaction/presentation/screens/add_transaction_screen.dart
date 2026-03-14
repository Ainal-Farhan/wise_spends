// add_transaction_screen.dart — enhanced version
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/saving/data/repositories/i_saving_repository.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/category/data/repositories/i_category_repository.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_bloc.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_event.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_bloc.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_event.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_state.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_state.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_account_selector.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_amount_field.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_category_grid.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_datetime_tile.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_locked_display.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_payee_picker.dart';
import 'package:wise_spends/features/transaction/presentation/widgets/transaction_type_toggle.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

class AddTransactionScreenArgs {
  final TransactionType? preselectedType;
  final String? editingTransactionId;
  final CommitmentTaskVO? existingCommitmentTaskVO;
  final TransactionEntity? existingTransaction;
  final CategoryEntity? existingCategory;
  final PayeeVO? existingPayee;
  final TimeOfDay? existingTime;

  const AddTransactionScreenArgs({
    this.preselectedType,
    this.editingTransactionId,
    this.existingTransaction,
    this.existingCommitmentTaskVO,
    this.existingCategory,
    this.existingPayee,
    this.existingTime,
  });
}

class AddTransactionScreen extends StatelessWidget {
  final AddTransactionScreenArgs? args;

  const AddTransactionScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) =>
              CategoryBloc(ctx.read<ICategoryRepository>())
                ..add(LoadCategoriesEvent()),
        ),
        BlocProvider(
          create: (ctx) => TransactionBloc(
            ctx.read<ITransactionRepository>(),
            ctx.read<ISavingRepository>(),
          ),
        ),
        BlocProvider(
          create: (ctx) =>
              SavingsBloc(ctx.read<ISavingRepository>())
                ..add(LoadSavingsListEvent()),
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
            if (a?.existingTransaction != null) {
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
      child: _AddTransactionScreenContent(args: args),
    );
  }
}

class _AddTransactionScreenContent extends StatefulWidget {
  final AddTransactionScreenArgs? args;
  const _AddTransactionScreenContent({this.args});

  @override
  State<_AddTransactionScreenContent> createState() =>
      _AddTransactionScreenContentState();
}

class _AddTransactionScreenContentState
    extends State<_AddTransactionScreenContent> {
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  bool _controllersSynced = false;

  bool get _isEditMode => widget.args?.editingTransactionId != null;

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
    if (!formState.isEditMode) {
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
                    _isEditMode
                        ? LockedTypeDisplay(formState: formState)
                        : TransactionTypeToggle(
                            selectedType: formState.transactionType,
                            onTypeSelected: (t) => context
                                .read<TransactionFormBloc>()
                                .add(ChangeTransactionType(t)),
                          ),
                    const SizedBox(height: 20),

                    // ── Amount ────────────────────────────────────────────
                    _isEditMode
                        ? LockedAmountDisplay(formState: formState)
                        : TransactionAmountField(
                            controller: _amountController,
                            transactionType: formState.transactionType,
                            typeColor: formState.transactionType.color,
                          ),
                    const SizedBox(height: 20),

                    // ── Account ───────────────────────────────────────────
                    _isEditMode
                        ? LockedAccountDisplay(formState: formState)
                        : _buildAccountSection(context, formState),
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
                      _isEditMode
                          ? LockedCategoryDisplay(formState: formState)
                          : TransactionCategoryGrid(formState: formState),
                      const SizedBox(height: 16),
                    ],

                    // ── Payee ─────────────────────────────────────────────
                    if (formState.supportsPayee) ...[
                      _isEditMode
                          ? LockedPayeeDisplay(formState: formState)
                          : TransactionPayeePicker(formState: formState),
                      const SizedBox(height: 16),
                    ],

                    TransactionDateTimePicker(formState: formState),
                    const SizedBox(height: 16),

                    // ── Note ──────────────────────────────────────────────
                    _buildNoteSection(context, formState),
                    const SizedBox(height: 28),

                    // ── Submit ────────────────────────────────────────────
                    _buildSubmitButton(context, formState),
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
  // Account section
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildAccountSection(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        final savingsList = state is SavingsListLoaded
            ? state.savingsList
            : <ListSavingVO>[];

        if (formState.transactionType == TransactionType.transfer) {
          return TransferAccountSelector(
            sourceAccountId: formState.selectedSourceAccount,
            destinationAccountId: formState.selectedDestinationAccount,
            savingsList: savingsList,
            onSourceChanged: (v) =>
                context.read<TransactionFormBloc>().add(SelectSourceAccount(v)),
            onDestinationChanged: (v) => context
                .read<TransactionFormBloc>()
                .add(SelectDestinationAccount(v)),
          );
        }

        final isIncome = formState.transactionType == TransactionType.income;
        return TransactionAccountDropdown(
          label: isIncome
              ? 'transaction.account.received_into'.tr
              : 'transaction.account.paid_from'.tr,
          hint: isIncome
              ? 'transaction.account.received_hint'.tr
              : 'transaction.account.paid_hint'.tr,
          selectedId: formState.selectedSourceAccount,
          savingsList: savingsList,
          onChanged: (v) =>
              context.read<TransactionFormBloc>().add(SelectSourceAccount(v)),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Note field
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildNoteSection(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    if (!formState.showNoteField) {
      return TextButton.icon(
        onPressed: () => context.read<TransactionFormBloc>().add(
          const ToggleNoteField(true),
        ),
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
      controller: _noteController,
      prefixIcon: Icons.note_alt_outlined,
      maxLines: 3,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Submit button
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSubmitButton(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionLoading;
        final label = formState.isEditMode
            ? (isLoading ? 'transaction.updating'.tr : 'transaction.update'.tr)
            : (isLoading ? 'transaction.saving'.tr : 'transaction.save'.tr);

        return AppButton.primary(
          label: label,
          isLoading: isLoading,
          isFullWidth: true,
          onPressed: isLoading ? null : () => _submit(context, formState),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
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

    if (formState.isEditMode && formState.editingTransactionId != null) {
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
