import 'package:flutter/material.dart';

void showDeleteDialog({
  required BuildContext context,
  required VoidCallback onDelete,
  VoidCallback? onCancelled,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Delete Box"),
      content: const Text("Delete the selected information?"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onDelete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully delete the selected information'),
              ),
            );
          },
          child: Container(
            color: Colors.red,
            padding: const EdgeInsets.all(14),
            child: const Text("Yes"),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            if (onCancelled != null) onCancelled();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cancel to delete the selected information'),
              ),
            );
          },
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.all(14),
            child: const Text("No"),
          ),
        ),
      ],
    ),
  );
}
