import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final Color? confirmColor;
  
  const ConfirmDeleteDialog({
    super.key,
    this.title = 'Confirm Delete',
    required this.content,
    this.cancelText = 'Cancel',
    this.confirmText = 'Delete',
    required this.onConfirm,
    this.confirmColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmText),
        ),
      ],
    );
  }

  // Static helper method for quick use
  static Future<void> show({
    required BuildContext context,
    String title = 'Confirm Delete',
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Delete',
    required VoidCallback onConfirm,
    Color? confirmColor = Colors.red,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ConfirmDeleteDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
        confirmColor: confirmColor,
      ),
    );
  }
}