import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_vo.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_event.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/add_commitment_form_state.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../widgets/shared/commitment_info_card.dart';
import '../widgets/shared/frequency_dropdown.dart';
import '../widgets/shared/savings_dropdown.dart';

class AddCommitmentScreen extends StatelessWidget {
  const AddCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CommitmentBloc()..add(const LoadCommitmentFormEvent()),
        ),
        BlocProvider(create: (_) => AddCommitmentFormBloc()),
      ],
      child: const _AddCommitmentContent(),
    );
  }
}

class _AddCommitmentContent extends StatefulWidget {
  const _AddCommitmentContent();

  @override
  State<_AddCommitmentContent> createState() => _AddCommitmentContentState();
}

class _AddCommitmentContentState extends State<_AddCommitmentContent> {
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
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CommitmentStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CommitmentStateCommitmentFormLoaded) {
            return _buildForm(context, state.savingVOList);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<ListSavingVO> savingVOList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommitmentInfoCard(
              icon: Icons.calendar_month,
              title: 'What is a Commitment?',
              subtitle:
                  'Recurring expenses like rent, insurance, or subscriptions',
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Commitment Name',
              controller: _nameController,
              hint: 'e.g., Monthly Rent, Car Insurance, Netflix',
              prefixIcon: Icons.label_outline,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a commitment name'
                  : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description (Optional)',
              controller: _descriptionController,
              hint: 'Additional details about this commitment',
              prefixIcon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const CommitmentInfoCard(
              icon: Icons.info_outline,
              title: 'Total Amount',
              subtitle:
                  'Add details below to define payment amounts. Total is calculated automatically.',
            ),
            const SizedBox(height: 24),
            Text('commitments.frequency'.tr, style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final freq = formState is AddCommitmentFormReady
                    ? formState.frequency
                    : 'monthly';
                return FrequencyDropdown(
                  value: freq,
                  onChanged: (v) {
                    if (v != null) {
                      context.read<AddCommitmentFormBloc>().add(
                        AddCommitmentChangeFrequency(v),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'commitments.link_savings'.tr,
              style: AppTextStyles.bodySemiBold,
            ),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final savingId = formState is AddCommitmentFormReady
                    ? formState.selectedSavingId
                    : null;
                return SavingsDropdown(
                  value: savingId,
                  savingVOList: savingVOList,
                  onChanged: (v) => context.read<AddCommitmentFormBloc>().add(
                    AddCommitmentSelectSaving(v),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<CommitmentBloc, CommitmentState>(
              builder: (context, state) {
                final isSaving = state is CommitmentStateLoading;
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: isSaving ? 'Creating...' : 'Create Commitment',
                        icon: Icons.add,
                        onPressed: isSaving
                            ? null
                            : () => _submit(context, savingVOList),
                        size: AppButtonSize.large,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.secondary(
                        label: 'general.cancel'.tr,
                        onPressed: () => Navigator.pop(context),
                        size: AppButtonSize.large,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context, List<ListSavingVO> savingVOList) {
    if (!_formKey.currentState!.validate()) return;

    final formState = context.read<AddCommitmentFormBloc>().state;
    final frequency = formState is AddCommitmentFormReady
        ? formState.frequency
        : 'monthly';
    final selectedSavingId = formState is AddCommitmentFormReady
        ? formState.selectedSavingId
        : null;

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

    final selectedSavingVO = savingVOList.firstWhere(
      (s) => s.saving.id == selectedSavingId,
      orElse: () => throw Exception('Selected savings not found'),
    );

    context.read<CommitmentBloc>().add(
      SaveCommitmentEvent(
        CommitmentVO()
          ..name = _nameController.text.trim()
          ..description = _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim()
          ..totalAmount = 0.0
          ..frequency = frequency
          ..referredSavingVO = SavingVO.fromSvngSaving(selectedSavingVO.saving),
      ),
    );
  }
}
