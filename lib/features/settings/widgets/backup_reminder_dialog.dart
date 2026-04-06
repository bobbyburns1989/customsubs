import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(AppSizes.base),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.backup_outlined,
          size: 32,
          color: context.colors.primary,
        ),
      ),
      title: Text(
        l10n.backupReminderTitle,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.backupReminderBody,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.base),
          Text(
            l10n.backupReminderHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          CheckboxListTile(
            value: _dontShowAgain,
            onChanged: (value) async {
              await HapticUtils.selection(); // Checkbox feedback
              setState(() {
                _dontShowAgain = value ?? false;
              });
            },
            title: Text(
              l10n.backupReminderDontShow,
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
          onPressed: () async {
            await HapticUtils.light(); // Button tap feedback
            if (context.mounted) {
              Navigator.pop(context, _dontShowAgain);
            }
          },
          child: Text(l10n.backupReminderGotIt),
        ),
      ],
    );
  }
}
