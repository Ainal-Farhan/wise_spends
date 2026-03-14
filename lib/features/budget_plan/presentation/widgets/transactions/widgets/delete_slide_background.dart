import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

/// Red background revealed when the user swipes a card end-to-start.
/// Used identically by both deposit and spending cards.
class DeleteSlideBackground extends StatelessWidget {
  const DeleteSlideBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white, size: 22),
          const SizedBox(height: 2),
          Text(
            'Delete',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
