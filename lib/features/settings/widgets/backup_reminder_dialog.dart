import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// Backup reminder dialog shown after user adds their 3rd subscription.
///
/// Encourages users to back up their data to prevent data loss.
/// Shows a one-time tip with option to dismiss permanently.
///
/// ## Usage
/// ```dart
/// final dismissed = await showDialog<bool>(
///   context: context,
///   builder: (context) => const BackupReminderDialog(),
/// );
///
/// if (dismissed == true) {
///   // User clicked "Don't show again"
/// }
/// ```
class BackupReminderDialog extends StatefulWidget {
  const BackupReminderDialog({super.key});

  @override
  State<BackupReminderDialog> createState() => _BackupReminderDialogState();
}

class _BackupReminderDialogState extends State<BackupReminderDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(AppSizes.base),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.backup_outlined,
          size: 32,
          color: AppColors.primary,
        ),
      ),
      title: const Text(
        'Back Up Your Data',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You\'ve added 3 subscriptions! Consider backing up your data to prevent loss.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.base),
          Text(
            'You can export a backup anytime in Settings → Export Backup.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          CheckboxListTile(
            value: _dontShowAgain,
            onChanged: (value) {
              setState(() {
                _dontShowAgain = value ?? false;
              });
            },
            title: Text(
              'Don\'t show this again',
              style: theme.textTheme.bodySmall,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _dontShowAgain),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
