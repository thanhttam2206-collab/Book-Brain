import 'package:flutter/material.dart';

Future<bool> showChapterRewardPrompt(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Mở khóa chương'),
          content: const Text(
            'Xem một quảng cáo để mở khóa chương này và chương kế tiếp?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Để sau'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Xem quảng cáo'),
            ),
          ],
        ),
  );
  return confirmed ?? false;
}
