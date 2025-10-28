import 'package:flutter/material.dart';

class ThInputRadioFormFields extends StatelessWidget {
  final String label;
  final Map<String, dynamic> options;
  final dynamic value;
  final ValueChanged<dynamic>? onChanged;

  const ThInputRadioFormFields({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: value,
          onChanged: onChanged ?? (value) {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...options.entries.map((entry) {
                return RadioListTile<dynamic>(
                  title: Text(entry.key),
                  value: entry.value,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
