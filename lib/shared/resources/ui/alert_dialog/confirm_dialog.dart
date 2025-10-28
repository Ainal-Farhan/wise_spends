import 'package:flutter/material.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';

void showConfirmDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
  String? message,
  VoidCallback? onCancelled,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Confirmation Dialog"),
      content: Text(message ?? ""),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm();
          },
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.all(14),
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            if (onCancelled != null) onCancelled();
            showSnackBarMessage(context, 'You have cancelled the the request');
          },
          child: Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(14),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    ),
  );
}
