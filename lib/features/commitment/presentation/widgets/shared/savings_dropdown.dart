import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';

/// A dropdown for picking a savings account.
///
/// Used in [AddCommitmentScreen], [EditCommitmentScreen], and the task
/// add/edit bottom sheet (where it appears as source or target).
///
/// [label] lets callers change the field label for each context:
///   - 'Savings Account'       → commitment form (link a default account)
///   - 'Source Savings (From)' → task form internal transfer / third-party
///   - 'Target Savings (To)'   → task form internal transfer target
///
/// Set [includeNoneOption] to `true` (default) when an "unlinked" choice
/// should be offered (commitment form). Set to `false` in task pickers where
/// a savings account is mandatory.
class SavingsDropdown extends StatelessWidget {
  final String? value;
  final List<ListSavingVO> savingVOList;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool includeNoneOption;

  const SavingsDropdown({
    super.key,
    required this.value,
    required this.savingVOList,
    required this.onChanged,
    this.label = 'Savings Account',
    this.hint,
    this.prefixIcon = Icons.wallet,
    this.includeNoneOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 20),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      hint: hint != null ? Text(hint!) : Text('commitments.select_savings'.tr),
      items: [
        if (includeNoneOption)
          DropdownMenuItem(value: null, child: Text('commitments.none'.tr)),
        ...savingVOList.map(
          (s) => DropdownMenuItem<String>(
            value: s.saving.id,
            child: Text(s.saving.name ?? 'Unnamed'),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
