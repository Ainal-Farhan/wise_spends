import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';

/// A dropdown for picking a payee in the third-party payment task form.
///
/// Shows a "no payees" hint when [payeeVOList] is empty and disables itself
/// so the user understands they must add a payee first.
///
/// Example:
/// ```dart
/// PayeeDropdown(
///   value: selectedPayeeId,
///   payeeVOList: payees,
///   onChanged: (v) => setState(() => selectedPayeeId = v),
/// )
/// ```
class PayeeDropdown extends StatelessWidget {
  final String? value;
  final List<PayeeVO> payeeVOList;
  final ValueChanged<String?>? onChanged;

  const PayeeDropdown({
    super.key,
    required this.value,
    required this.payeeVOList,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = payeeVOList.isEmpty;

    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Payee',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      hint: Text(
        isEmpty
            ? 'commitment_tasks.no_payees'.tr
            : 'commitment_tasks.select_payee'.tr,
      ),
      items: payeeVOList
          .map(
            (p) => DropdownMenuItem<String>(
              value: p.id,
              child: Text(p.name ?? 'Unnamed Payee'),
            ),
          )
          .toList(),
      onChanged: isEmpty ? null : onChanged,
    );
  }
}
