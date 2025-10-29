import 'package:flutter/material.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';

void showDeleteDialog({
  required BuildContext context,
  required VoidCallback onDelete,
  bool autoDisplayMessage = true,
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
            if (autoDisplayMessage) {
              showSnackBarMessage(
                context,
                'Successfully delete the selected information',
              );
            }
          },
          child: Container(
            color: Colors.red,
            padding: const EdgeInsets.all(14),
            child: const Text("Yes", style: TextStyle(color: Colors.black)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            if (onCancelled != null) onCancelled();
            showSnackBarMessage(
              context,
              'Cancel to delete the selected information',
            );
          },
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.all(14),
            child: const Text("No", style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    ),
  );
}
