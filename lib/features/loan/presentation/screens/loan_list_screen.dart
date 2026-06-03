import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_list_bloc.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_list_event.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_list_state.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getLoanRepository();
    return BlocProvider(
      create: (_) => LoanListBloc(repo)..add(LoadLoansEvent()),
      child: const _LoanListContent(),
    );
  }
}

class _LoanListContent extends StatelessWidget {
  const _LoanListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('loan.title'.tr)),
      drawer: const NavigationSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLoanSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<LoanListBloc, LoanListState>(
        builder: (context, state) {
          if (state is LoanListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LoanError) {
            return Center(child: Text(state.message));
          }
          if (state is LoanListLoaded) {
            if (state.summaries.isEmpty) {
              return Center(child: Text('loan.empty'.tr));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.summaries.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final summary = state.summaries[index];
                final loan = summary.loan;
                final isSettled = loan.status == 'settled';
                return AppCard(
                  child: ListTile(
                    onTap: () =>
                        Navigator.pushNamed(
                          context,
                          AppRoutes.loanDetail,
                          arguments: loan.id,
                        ).then(
                          (_) => context.read<LoanListBloc>().add(
                            LoadLoansEvent(),
                          ),
                        ),
                    onLongPress: () =>
                        _confirmDelete(context, loan.id, loan.borrowerName),
                    title: Text(
                      loan.borrowerName,
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'loan.label_principal'.tr}: ${_currFmt.format(loan.principalAmount)}',
                        ),
                        Text(
                          '${'loan.label_outstanding'.tr}: ${_currFmt.format(summary.outstanding)}',
                          style: TextStyle(
                            color: summary.outstanding > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        Text(
                          'loan.label_loaned'.trWith(
                            {'date': _dateFmt.format(loan.loanDate)},
                          ),
                        ),
                        if (loan.dueDate != null)
                          Text(
                            'loan.label_due'.trWith(
                              {'date': _dateFmt.format(loan.dueDate!)},
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppBadge(
                          label: isSettled
                              ? 'loan.status_settled'.tr
                              : 'loan.status_active'.tr,
                          status: isSettled
                              ? AppBadgeStatus.success
                              : AppBadgeStatus.warning,
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('loan.delete_title'.tr),
        content: Text('loan.delete_confirm'.trWith({'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LoanListBloc>().add(DeleteLoanEvent(id));
            },
            child: Text(
              'general.delete'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLoanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddLoanSheet(
        onAdd:
            (borrowerName, principal, loanDate, dueDate, sourceSavingId, note) {
              context.read<LoanListBloc>().add(
                AddLoanEvent(
                  borrowerName: borrowerName,
                  principalAmount: principal,
                  loanDate: loanDate,
                  dueDate: dueDate,
                  sourceSavingId: sourceSavingId,
                  note: note,
                ),
              );
            },
      ),
    );
  }
}

class _AddLoanSheet extends StatefulWidget {
  final void Function(
    String borrowerName,
    double principalAmount,
    DateTime loanDate,
    DateTime? dueDate,
    String sourceSavingId,
    String? note,
  )
  onAdd;

  const _AddLoanSheet({required this.onAdd});

  @override
  State<_AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends State<_AddLoanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _loanDate = DateTime.now();
  DateTime? _dueDate;
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
    _borrowerCtrl.dispose();
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
              Text('loan.add'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _borrowerCtrl,
                label: 'loan.field_borrower'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountCtrl,
                label: 'loan.field_amount'.tr,
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
                  labelText: 'loan.field_source'.tr,
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
                  'loan.field_loan_date'.trWith(
                    {'date': _dateFmt.format(_loanDate)},
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _loanDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _loanDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dueDate != null
                      ? 'loan.field_due_date'.trWith(
                          {'date': _dateFmt.format(_dueDate!)},
                        )
                      : 'loan.field_due_date_empty'.tr,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.primary(
                label: 'loan.btn_add'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _borrowerCtrl.text.trim(),
                      double.parse(_amountCtrl.text),
                      _loanDate,
                      _dueDate,
                      _selectedSavingId!,
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
