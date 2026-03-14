// form_datetime_picker.dart
// Reusable date/time picker with bottom sheet
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _logger = WiseLogger();

class FormDateTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final String? label;
  final bool enabled;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final VoidCallback? onTimeCleared;

  const FormDateTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    this.label,
    this.enabled = true,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.onTimeCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) _SectionLabel(text: label!),
        if (label != null) const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? () => _openSheet(context) : null,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: enabled ? AppColors.surface : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: enabled ? AppColors.divider : AppColors.border,
                ),
              ),
              child: Row(
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label ?? 'transaction.add.date_time'.tr,
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
                              _formatDate(selectedDate),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '·',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(context, selectedTime),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: selectedTime != null
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (enabled)
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
    _logger.debug(
      'Opening date/time picker, current date: ${_formatDate(selectedDate)}',
      tag: 'FormDateTimePicker',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DateTimeSheet(
        initialDate: selectedDate,
        initialTime: selectedTime,
        onDateChanged: onDateChanged,
        onTimeChanged: onTimeChanged,
        onTimeCleared: onTimeCleared,
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

  String _formatTime(BuildContext context, TimeOfDay? time) {
    if (time == null) return 'transaction.add.time_not_set'.tr;
    return time.format(context);
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
  final VoidCallback? onTimeCleared;

  const _DateTimeSheet({
    required this.initialDate,
    required this.initialTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.onTimeCleared,
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
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() => _date = picked);
      widget.onDateChanged(picked);
      _logger.debug(
        'Date changed to: ${_formatDate(picked)}',
        tag: 'FormDateTimePicker',
      );
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
      _logger.debug(
        'Time changed to: ${picked.format(context)}',
        tag: 'FormDateTimePicker',
      );
    }
  }

  void _clearTime() {
    setState(() => _time = null);
    widget.onTimeCleared?.call();
    _logger.debug('Time cleared', tag: 'FormDateTimePicker');
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
                    value: timeSet ? _time!.format(context) : 'transaction.add.time_not_set'.tr,
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
                  color: isValueSet ? AppColors.primary : AppColors.textSecondary,
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
                        color: isValueSet ? AppColors.textPrimary : AppColors.textHint,
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

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.bodySemiBold);
  }
}
