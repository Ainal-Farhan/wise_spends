import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_event.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_state.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('commitments.add'.tr)),
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
            const SizedBox(height: 24),

            // Info Card about Tasks
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: AppColors.tertiary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: AppTextStyles.bodySemiBold,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Add tasks below to define payment amounts. Total will be calculated automatically.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Frequency — value driven by AddCommitmentFormBloc, no setState
            Text('commitments.frequency'.tr, style: AppTextStyles.bodySemiBold),
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
                    items: [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('commitments.monthly'.tr),
                      ),
                      DropdownMenuItem(
                        value: 'quarterly',
                        child: Text('commitments.quarterly'.tr),
                      ),
                      DropdownMenuItem(value: 'yearly', child: Text('commitments.yearly'.tr)),
                      DropdownMenuItem(
                        value: 'biweekly',
                        child: Text('commitments.bi_weekly'.tr),
                      ),
                      DropdownMenuItem(value: 'weekly', child: Text('commitments.weekly'.tr)),
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
            Text('commitments.link_savings'.tr, style: AppTextStyles.bodySemiBold),
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
                  hint: Text('commitments.select_savings'.tr),
                  items: [
                    DropdownMenuItem(value: null, child: Text('commitments.none'.tr)),
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

    // Read frequency and savingId from BLoC
    final formState = context.read<AddCommitmentFormBloc>().state;
    final frequency = formState is AddCommitmentFormReady
        ? formState.frequency
        : 'monthly';
    final selectedSavingId = formState is AddCommitmentFormReady
        ? formState.selectedSavingId
        : null;

    // Validate savings account is selected
    if (selectedSavingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('commitments.select_savings_required'.tr),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Get savings list from commitment bloc state to find the selected savings
    final commitmentState = context.read<CommitmentBloc>().state;
    List<ListSavingVO> savingVOList = [];
    if (commitmentState is CommitmentStateCommitmentFormLoaded) {
      savingVOList = commitmentState.savingVOList;
    }

    // Find the selected savings VO
    final selectedSavingVO = savingVOList.firstWhere(
      (s) => s.saving.id == selectedSavingId,
      orElse: () => throw Exception('Selected savings not found'),
    );

    // Create commitment with the selected savings account
    final commitmentVO = CommitmentVO()
      ..name = _nameController.text.trim()
      ..description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()
      ..totalAmount =
          0.0 // Will be calculated from tasks
      ..frequency = frequency
      ..referredSavingVO = SavingVO.fromSvngSaving(selectedSavingVO.saving);

    context.read<CommitmentBloc>().add(SaveCommitmentEvent(commitmentVO));
  }
}
