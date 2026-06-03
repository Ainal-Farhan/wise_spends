import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_list_bloc.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_list_event.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_list_state.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class CreditCardListScreen extends StatelessWidget {
  const CreditCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCreditCardRepository();
    return BlocProvider(
      create: (_) => CreditCardListBloc(repo)..add(LoadCreditCardsEvent()),
      child: const _CreditCardListContent(),
    );
  }
}

class _CreditCardListContent extends StatelessWidget {
  const _CreditCardListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('credit_card.title'.tr)),
      drawer: const NavigationSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<CreditCardListBloc, CreditCardListState>(
        builder: (context, state) {
          if (state is CreditCardListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CreditCardError) {
            return Center(child: Text(state.message));
          }
          if (state is CreditCardListLoaded) {
            if (state.summaries.isEmpty) {
              return Center(child: Text('credit_card.empty'.tr));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.summaries.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final summary = state.summaries[index];
                final card = summary.card;
                final fmt = NumberFormat.currency(symbol: 'RM ');
                return AppCard(
                  child: ListTile(
                    onTap: () =>
                        Navigator.pushNamed(
                          context,
                          AppRoutes.creditCardDetail,
                          arguments: card.id,
                        ).then(
                          (_) => context.read<CreditCardListBloc>().add(
                            LoadCreditCardsEvent(),
                          ),
                        ),
                    onLongPress: () =>
                        _confirmDelete(context, card.id, card.name),
                    title: Text(
                      card.lastFourDigits != null
                          ? '${card.name} •••• ${card.lastFourDigits}'
                          : card.name,
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'credit_card.label_limit'.tr}: ${fmt.format(card.creditLimit)}',
                        ),
                        Text(
                          '${'credit_card.label_debt'.tr}: ${fmt.format(summary.totalDebt)}',
                          style: TextStyle(
                            color: summary.totalDebt > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        Text(
                          '${'credit_card.label_available'.tr}: ${fmt.format(summary.availableCredit)}',
                        ),
                        Text(
                          'credit_card.label_due_day'.trWith(
                            {'day': card.dueDay.toString()},
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
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
        title: Text('credit_card.delete_title'.tr),
        content: Text(
          'credit_card.delete_confirm'.trWith({'name': name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CreditCardListBloc>().add(DeleteCreditCardEvent(id));
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

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => _AddCardSheet(
        onAdd: (name, last4, limit, stmtDay, dueDay, note) {
          context.read<CreditCardListBloc>().add(
            AddCreditCardEvent(
              name: name,
              lastFourDigits: last4,
              creditLimit: limit,
              statementDay: stmtDay,
              dueDay: dueDay,
              note: note,
            ),
          );
        },
      ),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  final void Function(
    String name,
    String? lastFourDigits,
    double creditLimit,
    int statementDay,
    int dueDay,
    String? note,
  )
  onAdd;

  const _AddCardSheet({required this.onAdd});

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _last4Ctrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _stmtDayCtrl = TextEditingController();
  final _dueDayCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _last4Ctrl.dispose();
    _limitCtrl.dispose();
    _stmtDayCtrl.dispose();
    _dueDayCtrl.dispose();
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
              Text('credit_card.add'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _nameCtrl,
                label: 'credit_card.field_name'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _last4Ctrl,
                label: 'credit_card.field_last4'.tr,
                keyboardType: AppTextFieldKeyboardType.number,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _limitCtrl,
                label: 'credit_card.field_limit'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'general.required'.tr;
                  if (double.tryParse(v) == null) {
                    return 'general.invalid_number'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _stmtDayCtrl,
                      label: 'credit_card.field_statement_day'.tr,
                      keyboardType: AppTextFieldKeyboardType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 31) return '1-31';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _dueDayCtrl,
                      label: 'credit_card.field_due_day'.tr,
                      keyboardType: AppTextFieldKeyboardType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 31) return '1-31';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.primary(
                label: 'credit_card.btn_add'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _nameCtrl.text.trim(),
                      _last4Ctrl.text.trim().isEmpty
                          ? null
                          : _last4Ctrl.text.trim(),
                      double.parse(_limitCtrl.text),
                      int.parse(_stmtDayCtrl.text),
                      int.parse(_dueDayCtrl.text),
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
