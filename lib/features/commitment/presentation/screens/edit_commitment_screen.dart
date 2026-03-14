import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_event.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_state.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';

/// Edit Commitment Screen - Edit existing commitment
class EditCommitmentScreen extends StatelessWidget {
  final CommitmentVO commitment;

  const EditCommitmentScreen({super.key, required this.commitment});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CommitmentBloc()
                ..add(LoadCommitmentFormEvent(commitmentVO: commitment)),
        ),
        BlocProvider(
          create: (context) =>
              AddCommitmentFormBloc()
                ..add(InitializeEditCommitmentFormEvent(commitment)),
        ),
      ],
      child: _EditCommitmentScreenContent(commitment: commitment),
    );
  }
}

class _EditCommitmentScreenContent extends StatefulWidget {
  final CommitmentVO commitment;

  const _EditCommitmentScreenContent({required this.commitment});

  @override
  State<_EditCommitmentScreenContent> createState() =>
      _EditCommitmentScreenContentState();
}

class _EditCommitmentScreenContentState
    extends State<_EditCommitmentScreenContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.commitment.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.commitment.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('commitments.edit_commitment'.tr)),
      body: BlocConsumer<CommitmentBloc, CommitmentState>(
        listener: (context, state) {
          if (state is CommitmentStateSuccess) {
            Navigator.of(context).pop();
          } else if (state is CommitmentStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
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
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Commitment',
                          style: AppTextStyles.bodySemiBold,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your recurring expense details',
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
              label: 'Description',
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
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.tertiary,
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
                              'Total is calculated from all commitment tasks. Add or edit tasks to update the total.',
                              style: AppTextStyles.caption.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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

            // Frequency
            Text('commitments.frequency'.tr, style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final selectedFrequency = formState is AddCommitmentFormReady
                    ? formState.frequency
                    : widget.commitment.frequency ?? 'monthly';

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
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
                      DropdownMenuItem(
                        value: 'yearly',
                        child: Text('commitments.yearly'.tr),
                      ),
                      DropdownMenuItem(
                        value: 'biweekly',
                        child: Text('commitments.bi_weekly'.tr),
                      ),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text('commitments.weekly'.tr),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
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

            // Linked Savings
            Text(
              'Link to Savings (Optional)',
              style: AppTextStyles.bodySemiBold,
            ),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final selectedSavingId = formState is AddCommitmentFormReady
                    ? formState.selectedSavingId
                    : widget.commitment.referredSavingVO?.savingId;

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
                    DropdownMenuItem(
                      value: null,
                      child: Text('commitments.none'.tr),
                    ),
                    ...savingVOList.map((saving) {
                      return DropdownMenuItem<String>(
                        value: saving.saving.id as String,
                        child: Text(saving.saving.name as String? ?? 'Unnamed'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    context.read<AddCommitmentFormBloc>().add(
                      AddCommitmentSelectSaving(value),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            BlocBuilder<CommitmentBloc, CommitmentState>(
              builder: (context, state) {
                final isSaving = state is CommitmentStateLoading;

                return SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: isSaving ? 'Updating...' : 'Update Commitment',
                    icon: Icons.edit,
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

    final formState = context.read<AddCommitmentFormBloc>().state;
    final frequency = formState is AddCommitmentFormReady
        ? formState.frequency
        : widget.commitment.frequency ?? 'monthly';
    final selectedSavingId = formState is AddCommitmentFormReady
        ? formState.selectedSavingId
        : widget.commitment.referredSavingVO?.savingId;

    // Validate savings account is selected
    if (selectedSavingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('commitments.select_savings_required'.tr),
          backgroundColor: Theme.of(context).colorScheme.error,
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

    // Find the selected savings VO (or use existing if not changed)
    SavingVO? selectedSavingVO;
    if (selectedSavingId != widget.commitment.referredSavingVO?.savingId) {
      // Savings changed, find the new one
      final selectedListSaving = savingVOList.firstWhere(
        (s) => s.saving.id == selectedSavingId,
        orElse: () => savingVOList.first,
      );
      selectedSavingVO = SavingVO.fromSvngSaving(selectedListSaving.saving);
    } else {
      // Savings unchanged, use existing
      selectedSavingVO = widget.commitment.referredSavingVO;
    }

    // Update commitment without changing total - total is calculated from tasks
    final commitmentVO = CommitmentVO()
      ..commitmentId = widget.commitment.commitmentId
      ..name = _nameController.text.trim()
      ..description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()
      ..totalAmount = widget
          .commitment
          .totalAmount // Keep existing total
      ..frequency = frequency
      ..referredSavingVO = selectedSavingVO
      ..commitmentDetailVOList = widget.commitment.commitmentDetailVOList;

    context.read<CommitmentBloc>().add(SaveCommitmentEvent(commitmentVO));
  }
}
