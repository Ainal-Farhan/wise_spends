import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_detail_bloc.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_detail_event.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_detail_state.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

class CreditCardDetailScreen extends StatelessWidget {
  final String cardId;

  const CreditCardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
    return BlocProvider(
      create: (_) => CreditCardDetailBloc(
        locator.getCreditCardRepository(),
        locator.getCreditCardChargeRepository(),
        locator.getCreditCardPaymentRepository(),
      )..add(LoadCreditCardDetailEvent(cardId)),
      child: const _CreditCardDetailContent(),
    );
  }
}

class _CreditCardDetailContent extends StatefulWidget {
  const _CreditCardDetailContent();

  @override
  State<_CreditCardDetailContent> createState() =>
      _CreditCardDetailContentState();
}

class _CreditCardDetailContentState extends State<_CreditCardDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreditCardDetailBloc, CreditCardDetailState>(
      builder: (context, state) {
        if (state is CreditCardDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CreditCardDetailError) {
          return Scaffold(
            appBar: AppBar(title: Text('general.error'.tr)),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is CreditCardDetailLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text(state.card.name)),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'charge',
                  onPressed: () => _showAddChargeSheet(context, state.card.id),
                  label: Text('credit_card.add_charge'.tr),
                  icon: const Icon(Icons.add_shopping_cart),
                ),
                const SizedBox(height: AppSpacing.sm),
                FloatingActionButton.extended(
                  heroTag: 'payment',
                  onPressed: () => _showAddPaymentSheet(
                    context,
                    state.card.id,
                    state.charges,
                  ),
                  label: Text('credit_card.make_payment'.tr),
                  icon: const Icon(Icons.payment),
                ),
              ],
            ),
            body: Column(
              children: [
                _CardHeader(state: state),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'credit_card.tab_charges'.tr),
                    Tab(text: 'credit_card.tab_payments'.tr),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ChargesList(
                        charges: state.charges,
                        onDelete: (id) => context
                            .read<CreditCardDetailBloc>()
                            .add(DeleteChargeEvent(id)),
                      ),
                      _PaymentsList(payments: state.payments),
                    ],
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

  void _showAddChargeSheet(BuildContext context, String cardId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddChargeSheet(
        onAdd: (desc, amount, categoryId, date, note) {
          context.read<CreditCardDetailBloc>().add(
            AddChargeEvent(
              creditCardId: cardId,
              description: desc,
              amount: amount,
              categoryId: categoryId,
              chargeDate: date,
              note: note,
            ),
          );
        },
      ),
    );
  }

  void _showAddPaymentSheet(
    BuildContext context,
    String cardId,
    List<CrdCardCharge> charges,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddPaymentSheet(
        charges: charges,
        onAdd: (amount, sourceSavingId, date, note, allocations) {
          context.read<CreditCardDetailBloc>().add(
            AddPaymentEvent(
              creditCardId: cardId,
              sourceSavingId: sourceSavingId,
              amount: amount,
              paymentDate: date,
              note: note,
              chargeAllocations: allocations,
            ),
          );
        },
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final CreditCardDetailLoaded state;

  const _CardHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final card = state.card;
    final available = card.creditLimit - state.totalDebt;
    return AppCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.lastFourDigits != null
                  ? '${card.name} •••• ${card.lastFourDigits}'
                  : card.name,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label: 'credit_card.label_limit'.tr,
                  value: _currFmt.format(card.creditLimit),
                ),
                _StatChip(
                  label: 'credit_card.label_debt'.tr,
                  value: _currFmt.format(state.totalDebt),
                  valueColor: state.totalDebt > 0 ? Colors.red : Colors.green,
                ),
                _StatChip(
                  label: 'credit_card.label_available'.tr,
                  value: _currFmt.format(available.clamp(0, double.infinity)),
                  valueColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'credit_card.statement_due'.trWith({
                'stmt': card.statementDay.toString(),
                'due': card.dueDay.toString(),
              }),
              style: Theme.of(context).textTheme.bodySmall,
            ),
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

class _ChargesList extends StatelessWidget {
  final List<CrdCardCharge> charges;
  final void Function(String id) onDelete;

  const _ChargesList({required this.charges, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (charges.isEmpty) {
      return Center(child: Text('credit_card.charges_empty'.tr));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: charges.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final charge = charges[index];
        return AppCard(
          child: ListTile(
            title: Text(charge.description),
            subtitle: Text(_dateFmt.format(charge.chargeDate)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AmountText(amount: charge.amount),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDelete(charge.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentsList extends StatelessWidget {
  final List<CrdCardPayment> payments;

  const _PaymentsList({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(child: Text('credit_card.payments_empty'.tr));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: payments.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final payment = payments[index];
        return AppCard(
          child: ListTile(
            title: Text(_dateFmt.format(payment.paymentDate)),
            subtitle: payment.note != null ? Text(payment.note!) : null,
            trailing: AmountText(amount: payment.amount),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────
// Add Charge Bottom Sheet
// ─────────────────────────────────────────────────

class _AddChargeSheet extends StatefulWidget {
  final void Function(
    String description,
    double amount,
    String? categoryId,
    DateTime chargeDate,
    String? note,
  )
  onAdd;

  const _AddChargeSheet({required this.onAdd});

  @override
  State<_AddChargeSheet> createState() => _AddChargeSheetState();
}

class _AddChargeSheetState extends State<_AddChargeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _chargeDate = DateTime.now();

  @override
  void dispose() {
    _descCtrl.dispose();
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
              Text('credit_card.add_charge'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'credit_card.charge_description'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountCtrl,
                label: 'credit_card.charge_amount'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'general.must_be_positive'.tr;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'credit_card.charge_date'.trWith(
                    {'date': _dateFmt.format(_chargeDate)},
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _chargeDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _chargeDate = picked);
                },
              ),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.primary(
                label: 'credit_card.charge_btn'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _descCtrl.text.trim(),
                      double.parse(_amountCtrl.text),
                      null,
                      _chargeDate,
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

// ─────────────────────────────────────────────────
// Add Payment Bottom Sheet
// ─────────────────────────────────────────────────

class _AddPaymentSheet extends StatefulWidget {
  final List<CrdCardCharge> charges;
  final void Function(
    double amount,
    String sourceSavingId,
    DateTime paymentDate,
    String? note,
    List<({String chargeId, double amount})>? chargeAllocations,
  )
  onAdd;

  const _AddPaymentSheet({required this.charges, required this.onAdd});

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  String? _selectedSavingId;
  bool _allocate = false;
  final Map<String, TextEditingController> _allocationCtrls = {};
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
    for (final c in _allocationCtrls.values) {
      c.dispose();
    }
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
              Text('credit_card.make_payment'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _amountCtrl,
                label: 'credit_card.payment_amount'.tr,
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
                  labelText: 'credit_card.payment_source'.tr,
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
                validator: (v) =>
                    v == null ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'credit_card.payment_date'.trWith(
                    {'date': _dateFmt.format(_paymentDate)},
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _paymentDate = picked);
                },
              ),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (widget.charges.isNotEmpty)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('credit_card.payment_allocate'.tr),
                  value: _allocate,
                  onChanged: (v) => setState(() => _allocate = v),
                ),
              if (_allocate) ..._buildAllocationFields(),
              const SizedBox(height: AppSpacing.md),
              AppButton.primary(
                label: 'credit_card.payment_btn'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    List<({String chargeId, double amount})>? allocations;
                    if (_allocate) {
                      allocations = _allocationCtrls.entries
                          .map(
                            (e) => (
                              chargeId: e.key,
                              amount: double.tryParse(e.value.text) ?? 0,
                            ),
                          )
                          .where((a) => a.amount > 0)
                          .toList();
                    }
                    widget.onAdd(
                      double.parse(_amountCtrl.text),
                      _selectedSavingId!,
                      _paymentDate,
                      _noteCtrl.text.trim().isEmpty
                          ? null
                          : _noteCtrl.text.trim(),
                      allocations,
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

  List<Widget> _buildAllocationFields() {
    return widget.charges.map((charge) {
      _allocationCtrls.putIfAbsent(charge.id, () => TextEditingController());
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: AppTextField(
          controller: _allocationCtrls[charge.id],
          label: '${charge.description} (${_currFmt.format(charge.amount)})',
          keyboardType: AppTextFieldKeyboardType.decimal,
        ),
      );
    }).toList();
  }
}
