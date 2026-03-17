import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// A two-column label/value row used inside detail dialogs and confirm sheets.
///
/// Example:
/// ```dart
/// DetailRow(label: 'Amount', value: 'RM 500.00')
/// DetailRow(label: 'Status', value: null)  // renders '—'
/// ```
class DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
