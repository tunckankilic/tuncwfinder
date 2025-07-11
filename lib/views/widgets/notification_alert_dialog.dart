import 'package:flutter/material.dart';

class NotificationAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onTap;

  const NotificationAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text('Görüntüle'),
          ),
      ],
    );
  }
}
