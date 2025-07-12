import 'package:flutter/material.dart';
import 'package:tuncforwork/constants/app_strings.dart';

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
          child: Text(AppStrings.closeButton),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(AppStrings.viewButton),
          ),
      ],
    );
  }
}
