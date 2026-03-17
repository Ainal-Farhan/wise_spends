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

class EditCommitmentScreen extends StatelessWidget {
  final CommitmentVO commitment;

  const EditCommitmentScreen({super.key, required this.commitment});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              CommitmentBloc()
                ..add(LoadCommitmentFormEvent(commitmentVO: commitment)),
        ),
        BlocProvider(
          create: (_) =>
              AddCommitmentFormBloc()
                ..add(InitializeEditCommitmentFormEvent(commitment)),
        ),
      ],
      child: _EditCommitmentContent(commitment: commitment),
    );
  }
}

class _EditCommitmentContent extends StatefulWidget {
  final CommitmentVO commitment;
  const _EditCommitmentContent({required this.commitment});

  @override
  State<_EditCommitmentContent> createState() => _EditCommitmentContentState();
}

class _EditCommitmentContentState extends State<_EditCommitmentContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

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
              icon: Icons.edit,
              title: 'Edit Commitment',
              subtitle: 'Update your recurring expense details',
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
                  'Total is calculated from all commitment details. Add or edit details to update the total.',
            ),
            const SizedBox(height: 24),
            Text('commitments.frequency'.tr, style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final freq = formState is AddCommitmentFormReady
                    ? formState.frequency
                    : widget.commitment.frequency ?? 'monthly';
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
              'Link to Savings (Optional)',
              style: AppTextStyles.bodySemiBold,
            ),
            const SizedBox(height: 8),
            BlocBuilder<AddCommitmentFormBloc, AddCommitmentFormState>(
              builder: (context, formState) {
                final savingId = formState is AddCommitmentFormReady
                    ? formState.selectedSavingId
                    : widget.commitment.referredSavingVO?.savingId;
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
                        label: isSaving ? 'Updating...' : 'Update Commitment',
                        icon: Icons.edit,
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
        : widget.commitment.frequency ?? 'monthly';
    final selectedSavingId = formState is AddCommitmentFormReady
        ? formState.selectedSavingId
        : widget.commitment.referredSavingVO?.savingId;

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

    SavingVO? selectedSavingVO;
    if (selectedSavingId != widget.commitment.referredSavingVO?.savingId) {
      final match = savingVOList.firstWhere(
        (s) => s.saving.id == selectedSavingId,
        orElse: () => savingVOList.first,
      );
      selectedSavingVO = SavingVO.fromSvngSaving(match.saving);
    } else {
      selectedSavingVO = widget.commitment.referredSavingVO;
    }

    context.read<CommitmentBloc>().add(
      SaveCommitmentEvent(
        CommitmentVO()
          ..commitmentId = widget.commitment.commitmentId
          ..name = _nameController.text.trim()
          ..description = _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim()
          ..totalAmount = widget.commitment.totalAmount
          ..frequency = frequency
          ..referredSavingVO = selectedSavingVO
          ..commitmentDetailVOList = widget.commitment.commitmentDetailVOList,
      ),
    );
  }
}
