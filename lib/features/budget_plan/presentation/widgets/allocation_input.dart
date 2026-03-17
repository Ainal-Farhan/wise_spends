import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Reusable allocation input widget with slider and manual input
class AllocationInput extends StatefulWidget {
  final double initialValue;
  final double maxAmount;
  final String label;
  final ValueChanged<double> onChanged;
  final String? Function(double?)? validator;
  final bool isLoading;

  const AllocationInput({
    super.key,
    required this.initialValue,
    required double maxAmount,
    required this.label,
    required this.onChanged,
    this.validator,
    this.isLoading = false,
  }) : maxAmount = maxAmount < 0 ? .0 : maxAmount;

  @override
  State<AllocationInput> createState() => _AllocationInputState();
}

class _AllocationInputState extends State<AllocationInput> {
  late TextEditingController _amountCtrl;
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialValue.clamp(0, widget.maxAmount);
    _amountCtrl = TextEditingController(text: _sliderValue.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AllocationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.maxAmount != oldWidget.maxAmount) {
      _sliderValue = widget.initialValue.clamp(0, widget.maxAmount);
      _amountCtrl.text = _sliderValue.toStringAsFixed(2);
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
      _amountCtrl.text = value.toStringAsFixed(2);
    });
    widget.onChanged(value);
  }

  void _onTextChanged(String value) {
    final amount = double.tryParse(value);
    if (amount != null) {
      setState(() {
        _sliderValue = amount.clamp(0, widget.maxAmount);
      });
      widget.onChanged(_sliderValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          // Slider section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'RM ${_sliderValue.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Theme.of(context).colorScheme.tertiary,
              inactiveTrackColor: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.3),
              thumbColor: Theme.of(context).colorScheme.tertiary,
              overlayColor: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _sliderValue.clamp(0, widget.maxAmount),
              min: 0,
              max: widget.maxAmount,
              divisions: 100,
              label: 'RM ${_sliderValue.toStringAsFixed(2)}',
              onChanged: _onSliderChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Min/Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RM 0',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'RM ${widget.maxAmount.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Manual input field
          AppTextField(
            controller: _amountCtrl,
            label: 'budget_plans.manual_input'.tr,
            hint: '0.00',
            keyboardType: AppTextFieldKeyboardType.decimal,
            prefixText: 'RM ',
            onChanged: _onTextChanged,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'error.validation.required'.tr;
              }
              final amount = double.tryParse(v);
              if (amount == null || amount < 0) {
                return 'budget_plans.error.valid_amount'.tr;
              }
              if (amount > widget.maxAmount) {
                return 'budget_plans.error.amount_exceeds_max'.trWith({
                  'max': widget.maxAmount.toStringAsFixed(2),
                });
              }
              return widget.validator?.call(amount);
            },
          ),
        ],
      ],
    );
  }

  double get value => _sliderValue;
}
