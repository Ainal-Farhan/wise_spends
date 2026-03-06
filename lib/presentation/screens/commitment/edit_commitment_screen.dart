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
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

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
      appBar: AppBar(title: const Text('Edit Commitment')),
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
                      Icons.edit,
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
                              'Total is calculated from all commitment tasks. Add or edit tasks to update the total.',
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

            // Frequency
            Text('Frequency', style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final selectedFrequency = formState is AddCommitmentFormReady
                    ? formState.frequency
                    : widget.commitment.frequency ?? 'monthly';

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
          content: const Text('Please select a savings account'),
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
