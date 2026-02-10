import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/services/backup_service.dart';
import 'package:custom_subs/data/services/undo_service.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/features/settings/widgets/currency_picker_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryCurrency = ref.watch(primaryCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await HapticUtils.light();
            if (context.mounted) {
              context.pop();
            }
          },
        ),
      ),
      body: ListView(
        children: [
          // General section
          const _SectionHeader(title: 'General'),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Primary Currency'),
            subtitle: Text(
              '$primaryCurrency - ${CurrencyUtils.getCurrencyName(primaryCurrency)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await HapticUtils.light(); // ListTile tap feedback

              final selected = await showDialog<String>(
                context: context,
                builder: (context) => CurrencyPickerDialog(
                  currentCurrency: primaryCurrency,
                ),
              );

              if (selected != null && selected != primaryCurrency) {
                await HapticUtils.medium(); // Setting changed feedback

                // Cache previous currency for UNDO
                final undoService = UndoService();
                undoService.cacheCurrencyChange(primaryCurrency);

                await ref.read(settingsRepositoryProvider.notifier)
                    .setPrimaryCurrency(selected);

                if (context.mounted) {
                  SnackBarUtils.show(
                    context,
                    SnackBarUtils.success(
                      'Currency changed to $selected',
                      onUndo: () async {
                        await HapticUtils.medium();
                        final previous = undoService.getPreviousCurrency();
                        if (previous != null) {
                          await ref.read(settingsRepositoryProvider.notifier)
                              .setPrimaryCurrency(previous);
                          if (context.mounted) {
                            SnackBarUtils.show(
                              context,
                              SnackBarUtils.info('Currency restored to $previous'),
                            );
                          }
                        }
                      },
                    ),
                  );
                }
              }
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final settingsAsync = ref.watch(settingsRepositoryProvider);
              final defaultReminderTime = settingsAsync.when(
                data: (_) {
                  final repository = ref.read(settingsRepositoryProvider.notifier);
                  final hour = repository.getDefaultReminderHour();
                  final minute = repository.getDefaultReminderMinute();
                  return TimeOfDay(hour: hour, minute: minute);
                },
                loading: () => const TimeOfDay(hour: 9, minute: 0),
                error: (_, __) => const TimeOfDay(hour: 9, minute: 0),
              );

              return ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Default Reminder Time'),
                subtitle: Text(
                  '${defaultReminderTime.hour.toString().padLeft(2, '0')}:${defaultReminderTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await HapticUtils.light(); // ListTile tap feedback

                  final time = await showTimePicker(
                    context: context,
                    initialTime: defaultReminderTime,
                  );

                  if (time != null) {
                    await HapticUtils.medium(); // Setting changed feedback

                    // Cache previous time for UNDO
                    final undoService = UndoService();
                    undoService.cacheReminderTimeChange(defaultReminderTime);

                    await ref.read(settingsRepositoryProvider.notifier)
                        .setDefaultReminderTime(time.hour, time.minute);

                    if (context.mounted) {
                      SnackBarUtils.show(
                        context,
                        SnackBarUtils.success(
                          'Reminder time updated',
                          onUndo: () async {
                            await HapticUtils.medium();
                            final previous = undoService.getPreviousReminderTime();
                            if (previous != null) {
                              await ref.read(settingsRepositoryProvider.notifier)
                                  .setDefaultReminderTime(previous.hour, previous.minute);
                              if (context.mounted) {
                                SnackBarUtils.show(
                                  context,
                                  SnackBarUtils.info('Reminder time restored'),
                                );
                              }
                            }
                          },
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),

          const Divider(height: 1),

          // Notifications section
          const _SectionHeader(title: 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification now'),
            onTap: () async {
              await HapticUtils.medium(); // Action trigger feedback
              final notificationService = await ref.read(notificationServiceProvider.future);
              await notificationService.showTestNotification();

              if (context.mounted) {
                SnackBarUtils.show(
                  context,
                  SnackBarUtils.success('Test notification sent!'),
                );
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.base,
              vertical: AppSizes.sm,
            ),
            child: Text(
              'CustomSubs sends reminders at your chosen time before billing dates. Make sure notifications are enabled in your device settings.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const Divider(height: 1),

          // Data section
          const _SectionHeader(title: 'Data'),
          Consumer(
            builder: (context, ref, child) {
              final settingsAsync = ref.watch(settingsRepositoryProvider);
              final lastBackupDate = settingsAsync.when(
                data: (_) {
                  final repository = ref.read(settingsRepositoryProvider.notifier);
                  return repository.getLastBackupDate();
                },
                loading: () => null,
                error: (_, __) => null,
              );

              return ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Last Backup'),
                subtitle: Text(
                  lastBackupDate != null
                      ? _formatBackupDate(lastBackupDate)
                      : 'Never backed up',
                  style: TextStyle(
                    color: lastBackupDate == null ? AppColors.warning : null,
                    fontWeight:
                        lastBackupDate == null ? FontWeight.w600 : null,
                  ),
                ),
              );
            },
          ),
          Builder(
            builder: (context) {
              return ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Export Backup'),
                subtitle: const Text('Save your subscriptions to a file'),
                onTap: () async {
                  await HapticUtils.medium(); // Action trigger feedback

                  // Calculate share position origin for iOS before async gap
                  final box = context.findRenderObject() as RenderBox?;
                  final sharePositionOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;

                  try {
                    // Show loading indicator
                    if (context.mounted) {
                      SnackBarUtils.show(
                        context,
                        SnackBarUtils.info('Preparing backup...'),
                      );
                    }

                    // Export backup with position origin - call service directly
                    final backupService = await ref.read(backupServiceProvider.future);
                    final repository = await ref.read(subscriptionRepositoryProvider.future);
                    final subscriptions = repository.getAllActive();

                    await backupService.exportAndShare(
                      subscriptions,
                      sharePositionOrigin: sharePositionOrigin,
                    );

                    // Update last backup date
                    await ref.read(settingsRepositoryProvider.notifier)
                        .setLastBackupDate(DateTime.now());

                    if (context.mounted) {
                      SnackBarUtils.show(
                        context,
                        SnackBarUtils.success('Backup exported successfully!'),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      SnackBarUtils.show(
                        context,
                        SnackBarUtils.error('Failed to export backup: $e'),
                      );
                    }
                  }
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Backup'),
            subtitle: const Text('Restore subscriptions from a file'),
            onTap: () async {
              await HapticUtils.medium(); // Action trigger feedback
              try{
                // Import backup
                final result = await ref.read(importBackupProvider.future);

                if (context.mounted) {
                  // Show result dialog
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Import Complete'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Found: ${result.totalFound} subscriptions'),
                          Text('Duplicates skipped: ${result.duplicates}'),
                          Text('Imported: ${result.imported} subscriptions'),
                          if (result.imported > 0) ...[
                            const SizedBox(height: AppSizes.base),
                            const Text(
                              'Notifications have been scheduled for all imported subscriptions.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } on BackupException catch (e) {
                if (context.mounted) {
                  SnackBarUtils.show(
                    context,
                    SnackBarUtils.error(e.message),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarUtils.show(
                    context,
                    SnackBarUtils.error('Failed to import backup: $e'),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text(
              'Delete All Data',
              style: TextStyle(color: AppColors.error),
            ),
            subtitle: const Text('Permanently delete all subscriptions'),
            onTap: () async {
              await HapticUtils.light(); // ListTile tap feedback
              // First confirmation
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete All Data?'),
                  content: const Text(
                    'This will permanently delete all subscriptions and settings. This cannot be undone.\n\nAre you sure you want to continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              );

              if (confirmed != true || !context.mounted) return;

              // Second confirmation - type DELETE
              final textController = TextEditingController();
              final finalConfirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This action is irreversible. All your subscription data will be lost forever.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.base),
                      const Text('Type DELETE to confirm:'),
                      const SizedBox(height: AppSizes.sm),
                      TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'DELETE',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (textController.text == 'DELETE') {
                          Navigator.pop(context, true);
                        } else {
                          SnackBarUtils.show(
                            context,
                            SnackBarUtils.warning('Please type DELETE to confirm'),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );

              if (finalConfirmed != true || !context.mounted) return;

              // Delete all data
              try {
                await HapticUtils.heavy(); // Destructive action haptic
                final repository = await ref.read(subscriptionRepositoryProvider.future);
                final notificationService = await ref.read(notificationServiceProvider.future);

                // Cancel all notifications
                await notificationService.cancelAllNotifications();

                // Delete all subscriptions
                await repository.deleteAll();

                if (context.mounted) {
                  SnackBarUtils.show(
                    context,
                    SnackBarUtils.warning('All data deleted successfully'),
                  );

                  // Pop back to home
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarUtils.show(
                    context,
                    SnackBarUtils.error('Failed to delete data: $e'),
                  );
                }
              }
            },
          ),

          const Divider(height: 1),

          // About section
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () async {
              final url = Uri.parse('https://customsubs.us/privacy');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () async {
              final url = Uri.parse('https://customsubs.us/terms');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const ListTile(
            leading: Icon(Icons.favorite_outline),
            title: Text('Made with love by CustomApps LLC'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.base,
        AppSizes.xl,
        AppSizes.base,
        AppSizes.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Format backup date for display
String _formatBackupDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }
}
