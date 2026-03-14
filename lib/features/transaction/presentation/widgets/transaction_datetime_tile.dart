// transaction_datetime_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_state.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'transaction_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget — drop-in replacement for the two old DateTimeTile blocks
//
// Usage:
//   TransactionDateTimePicker(formState: formState),
// ─────────────────────────────────────────────────────────────────────────────

class TransactionDateTimePicker extends StatelessWidget {
  final TransactionFormReady formState;

  const TransactionDateTimePicker({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    final timeSet = formState.selectedTime != null;
    final dateStr = _formatDate(formState.selectedDate);
    final timeStr = timeSet
        ? formState.selectedTime!.format(context)
        : 'transaction.add.time_not_set'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: 'transaction.add.date_time'.tr),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openSheet(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  // Icon bubble
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Date · Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'transaction.add.date_time'.tr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '·',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              timeStr,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: timeSet
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    final bloc = context.read<TransactionFormBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DateTimeSheet(
        initialDate: formState.selectedDate,
        initialTime: formState.selectedTime,
        onDateChanged: (d) => bloc.add(ChangeTransactionDate(d)),
        onTimeChanged: (t) => bloc.add(ChangeTransactionTime(t)),
        onTimeClear: () => bloc.add(const ClearTransactionTime()),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'transaction.history.today'.tr;
    if (d == yesterday) return 'general.yesterday'.tr;
    if (date.year == now.year) return DateFormat('EEE, d MMM').format(date);
    return DateFormat('d MMM y').format(date);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _DateTimeSheet extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay? initialTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final VoidCallback onTimeClear;

  const _DateTimeSheet({
    required this.initialDate,
    required this.initialTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onTimeClear,
  });

  @override
  State<_DateTimeSheet> createState() => _DateTimeSheetState();
}

class _DateTimeSheetState extends State<_DateTimeSheet> {
  late DateTime _date;
  late TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _time = widget.initialTime;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'transaction.history.today'.tr;
    if (d == yesterday) return 'general.yesterday'.tr;
    if (date.year == now.year) return DateFormat('EEE, d MMM').format(date);
    return DateFormat('d MMM y').format(date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
      widget.onDateChanged(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _time = picked);
      widget.onTimeChanged(picked);
    }
  }

  void _clearTime() {
    setState(() => _time = null);
    widget.onTimeClear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final timeSet = _time != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('transaction.add.date_time'.tr, style: AppTextStyles.h3),
            const SizedBox(height: 16),

            // Date + Time value cards
            Row(
              children: [
                Expanded(
                  child: _SheetCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'transaction.add.date'.tr,
                    value: _formatDate(_date),
                    isValueSet: true,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetCard(
                    icon: Icons.access_time_rounded,
                    label: 'transaction.add.time'.tr,
                    value: timeSet
                        ? _time!.format(context)
                        : 'transaction.add.time_not_set'.tr,
                    isValueSet: timeSet,
                    onTap: _pickTime,
                    trailing: timeSet
                        ? GestureDetector(
                            onTap: _clearTime,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'transaction.add.change_date'.tr,
                    icon: Icons.calendar_today_rounded,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SheetButton(
                    label: 'transaction.add.change_time'.tr,
                    icon: Icons.access_time_rounded,
                    onTap: _pickTime,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SheetButton(
                    label: 'general.done'.tr,
                    isPrimary: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet value card
// ─────────────────────────────────────────────────────────────────────────────

class _SheetCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isValueSet;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SheetCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isValueSet,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isValueSet
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.divider,
              width: isValueSet ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isValueSet
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.divider.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: isValueSet
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textHint,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isValueSet
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet action button
// ─────────────────────────────────────────────────────────────────────────────

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    this.icon,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: isPrimary ? null : Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isPrimary ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
