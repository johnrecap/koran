import 'package:flutter/material.dart';

class NotificationTimePickerTile extends StatelessWidget {
  const NotificationTimePickerTile({
    super.key,
    required this.label,
    required this.time,
    required this.onPressed,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final formatted = MaterialLocalizations.of(context).formatTimeOfDay(time);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      subtitle: Text(formatted),
      trailing: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.schedule_rounded),
      ),
      onTap: onPressed,
    );
  }
}
