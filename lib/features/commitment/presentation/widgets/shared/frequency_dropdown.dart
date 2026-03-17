import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';

/// A dropdown for selecting how often a commitment recurs.
/// Used identically in [AddCommitmentScreen] and [EditCommitmentScreen].
///
/// Example:
/// ```dart
/// FrequencyDropdown(
///   value: selectedFrequency,
///   onChanged: (v) { if (v != null) setState(() => freq = v); },
/// )
/// ```
class FrequencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const FrequencyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Icon(Icons.calendar_today, size: 20),
      ),
      items: [
        DropdownMenuItem(
          value: 'monthly',
          child: Text('commitments.monthly'.tr),
        ),
        DropdownMenuItem(
          value: 'quarterly',
          child: Text('commitments.quarterly'.tr),
        ),
        DropdownMenuItem(value: 'yearly', child: Text('commitments.yearly'.tr)),
        DropdownMenuItem(
          value: 'biweekly',
          child: Text('commitments.bi_weekly'.tr),
        ),
        DropdownMenuItem(value: 'weekly', child: Text('commitments.weekly'.tr)),
      ],
      onChanged: onChanged,
    );
  }
}
