import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_detail_bloc.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_detail_event.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_detail_state.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

class LoanDetailScreen extends StatelessWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
    return BlocProvider(
      create: (_) => LoanDetailBloc(
        locator.getLoanRepository(),
        locator.getLoanRepaymentRepository(),
      )..add(LoadLoanDetailEvent(loanId)),
      child: const _LoanDetailContent(),
    );
  }
}

class _LoanDetailContent extends StatelessWidget {
  const _LoanDetailContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoanDetailBloc, LoanDetailState>(
      builder: (context, state) {
        if (state is LoanDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is LoanDetailError) {
          return Scaffold(
            appBar: AppBar(title: Text('general.error'.tr)),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is LoanDetailLoaded) {
          final isSettled = state.loan.status == 'settled';
          return Scaffold(
            appBar: AppBar(title: Text(state.loan.borrowerName)),
            floatingActionButton: isSettled
                ? null
                : FloatingActionButton.extended(
                    onPressed: () =>
                        _showAddRepaymentSheet(context, state.loan.id),
                    label: Text('loan.record_repayment'.tr),
                    icon: const Icon(Icons.payments_outlined),
                  ),
            body: Column(
              children: [
                _LoanHeader(state: state),
                if (!isSettled)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppButton.secondary(
                      label: 'loan.btn_settle'.tr,
                      onPressed: () => context.read<LoanDetailBloc>().add(
                        SettleLoanEvent(state.loan.id),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                SectionHeader(title: 'loan.repayments_title'.tr),
                Expanded(
                  child: state.repayments.isEmpty
                      ? Center(child: Text('loan.repayments_empty'.tr))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          itemCount: state.repayments.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.xs),
                          itemBuilder: (context, index) {
                            final r = state.repayments[index];
                            return AppCard(
                              child: ListTile(
                                title: Text(_dateFmt.format(r.repaymentDate)),
                                subtitle: r.note != null ? Text(r.note!) : null,
                                trailing: AmountText(amount: r.amount),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAddRepaymentSheet(BuildContext context, String loanId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddRepaymentSheet(
        onAdd: (amount, destinationSavingId, date, note) {
          context.read<LoanDetailBloc>().add(
            AddRepaymentEvent(
              loanId: loanId,
              amount: amount,
              destinationSavingId: destinationSavingId,
              repaymentDate: date,
              note: note,
            ),
          );
        },
      ),
    );
  }
}

class _LoanHeader extends StatelessWidget {
  final LoanDetailLoaded state;

  const _LoanHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final loan = state.loan;
    final isSettled = loan.status == 'settled';
    return AppCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loan.borrowerName, style: AppTextStyles.h3),
                AppBadge(
                  label: isSettled
                      ? 'loan.status_settled'.tr
                      : 'loan.status_active'.tr,
                  status: isSettled
                      ? AppBadgeStatus.success
                      : AppBadgeStatus.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label: 'loan.label_principal'.tr,
                  value: _currFmt.format(loan.principalAmount),
                ),
                _StatChip(
                  label: 'loan.label_outstanding'.tr,
                  value: _currFmt.format(state.outstanding),
                  valueColor: state.outstanding > 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'loan.label_loaned'.trWith({'date': _dateFmt.format(loan.loanDate)}),
            ),
            if (loan.dueDate != null)
              Text(
                'loan.label_due'.trWith({'date': _dateFmt.format(loan.dueDate!)}),
              ),
            if (loan.note != null)
              Text('loan.label_note'.trWith({'note': loan.note!})),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(color: valueColor)),
      ],
    );
  }
}

class _AddRepaymentSheet extends StatefulWidget {
  final void Function(
    double amount,
    String destinationSavingId,
    DateTime repaymentDate,
    String? note,
  )
  onAdd;

  const _AddRepaymentSheet({required this.onAdd});

  @override
  State<_AddRepaymentSheet> createState() => _AddRepaymentSheetState();
}

class _AddRepaymentSheetState extends State<_AddRepaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _repaymentDate = DateTime.now();
  String? _selectedSavingId;
  List<ListSavingVO> _savings = [];

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    try {
      final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getSavingRepository();
      final savings = await repo.getAllSavings();
      if (mounted) setState(() => _savings = savings);
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('loan.record_repayment'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _amountCtrl,
                label: 'loan.repayment_amount'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'general.must_be_positive'.tr;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'loan.repayment_destination'.tr,
                  border: const OutlineInputBorder(),
                ),
                initialValue: _selectedSavingId,
                items: _savings
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.saving.id,
                        child: Text(s.saving.name ?? s.saving.id),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedSavingId = v),
                validator: (v) => v == null ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'loan.repayment_date'.trWith(
                    {'date': _dateFmt.format(_repaymentDate)},
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _repaymentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _repaymentDate = picked);
                  }
                },
              ),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.primary(
                label: 'loan.repayment_btn'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      double.parse(_amountCtrl.text),
                      _selectedSavingId!,
                      _repaymentDate,
                      _noteCtrl.text.trim().isEmpty
                          ? null
                          : _noteCtrl.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
