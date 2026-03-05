import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/presentation/blocs/add_commitment_form/add_commitment_form_bloc.dart';
import 'package:wise_spends/presentation/blocs/add_commitment_form/add_commitment_form_event.dart';
import 'package:wise_spends/presentation/blocs/add_commitment_form/add_commitment_form_state.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';

/// Add Commitment Screen - Pure BLoC, no setState
class AddCommitmentScreen extends StatelessWidget {
  const AddCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CommitmentBloc()..add(const LoadCommitmentFormEvent()),
        ),
        BlocProvider(create: (context) => AddCommitmentFormBloc()),
      ],
      child: const _AddCommitmentScreenContent(),
    );
  }
}

// StatefulWidget kept only for TextEditingControllers — they require
// initState/dispose and have no BLoC equivalent for raw text input.
// All selection state (frequency, savingId) lives in AddCommitmentFormBloc.
class _AddCommitmentScreenContent extends StatefulWidget {
  const _AddCommitmentScreenContent();

  @override
  State<_AddCommitmentScreenContent> createState() =>
      _AddCommitmentScreenContentState();
}

class _AddCommitmentScreenContentState
    extends State<_AddCommitmentScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Commitment')),
      body: BlocConsumer<CommitmentBloc, CommitmentState>(
        listener: (context, state) {
          if (state is CommitmentStateSuccess) {
            Navigator.of(context).pop();
          } else if (state is CommitmentStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CommitmentStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CommitmentStateCommitmentFormLoaded) {
            return _buildForm(context, state.savingVOList);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<dynamic> savingVOList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: AppColors.tertiary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What is a Commitment?',
                          style: AppTextStyles.bodySemiBold,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recurring expenses like rent, insurance, or subscriptions',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Commitment Name
            AppTextField(
              label: 'Commitment Name',
              controller: _nameController,
              hint: 'e.g., Monthly Rent, Car Insurance, Netflix',
              prefixIcon: Icons.label_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a commitment name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            AppTextField(
              label: 'Description (Optional)',
              controller: _descriptionController,
              hint: 'Additional details about this commitment',
              prefixIcon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Amount
            AppTextField(
              label: 'Total Amount (RM)',
              controller: _amountController,
              prefixText: 'RM ',
              keyboardType: AppTextFieldKeyboardType.decimal,
              prefixIcon: Icons.attach_money,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Please enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Frequency — value driven by AddCommitmentFormBloc, no setState
            Text('Frequency', style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final selectedFrequency = formState is AddCommitmentFormReady
                    ? formState.frequency
                    : 'monthly';

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedFrequency,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: 'quarterly',
                        child: Text('Quarterly'),
                      ),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                      DropdownMenuItem(
                        value: 'biweekly',
                        child: Text('Bi-weekly'),
                      ),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        // Dispatch to BLoC only — no setState
                        context.read<AddCommitmentFormBloc>().add(
                          AddCommitmentChangeFrequency(value),
                        );
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Linked Savings — value driven by AddCommitmentFormBloc, no setState
            Text(
              'Link to Savings (Optional)',
              style: AppTextStyles.bodySemiBold,
            ),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final selectedSavingId = formState is AddCommitmentFormReady
                    ? formState.selectedSavingId
                    : null;

                return DropdownButtonFormField<String>(
                  initialValue: selectedSavingId,
                  decoration: const InputDecoration(
                    labelText: 'Savings Account',
                    prefixIcon: Icon(Icons.savings, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  hint: const Text('Select savings account'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...savingVOList.map((saving) {
                      return DropdownMenuItem<String>(
                        value: saving.saving.id as String,
                        child: Text(saving.saving.name as String? ?? 'Unnamed'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    // Dispatch to BLoC only — no setState
                    context.read<AddCommitmentFormBloc>().add(
                      AddCommitmentSelectSaving(value),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Create Button
            BlocBuilder<CommitmentBloc, CommitmentState>(
              builder: (context, state) {
                final isSaving = state is CommitmentStateLoading;

                return SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: isSaving ? 'Creating...' : 'Create Commitment',
                    icon: Icons.add,
                    onPressed: isSaving ? null : () => _submitForm(context),
                    size: AppButtonSize.large,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton.secondary(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
                size: AppButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    // Read frequency and savingId from BLoC — no local fields needed
    final formState = context.read<AddCommitmentFormBloc>().state;
    final frequency = formState is AddCommitmentFormReady
        ? formState.frequency
        : 'monthly';
    final selectedSavingId = formState is AddCommitmentFormReady
        ? formState.selectedSavingId
        : null;

    final amount = double.parse(_amountController.text.trim());

    final commitmentVO = CommitmentVO()
      ..name = _nameController.text.trim()
      ..description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()
      ..totalAmount = amount
      ..frequency = frequency;

    final detailVO = CommitmentDetailVO()
      ..amount = amount
      ..savingId = selectedSavingId;

    commitmentVO.commitmentDetailVOList = [detailVO];

    context.read<CommitmentBloc>().add(SaveCommitmentEvent(commitmentVO));
  }
}
