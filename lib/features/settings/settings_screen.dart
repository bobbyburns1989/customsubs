import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/services/backup_service.dart';
import 'package:custom_subs/data/services/undo_service.dart';
import 'package:custom_subs/data/services/demo_data_service.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/features/settings/widgets/currency_picker_dialog.dart';
import 'package:custom_subs/features/settings/widgets/custom_apps_promo_card.dart';
import 'package:custom_subs/core/providers/entitlement_provider.dart';
import 'package:custom_subs/core/constants/revenue_cat_constants.dart';
import 'package:custom_subs/data/services/analytics_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Easter egg tap counter — unlocks Developer Tools at 11 taps
  int _tapCount = 0;
  DateTime? _lastTapTime;
  bool _devToolsUnlocked = false;
  bool _isLoadingDemo = false;
  bool _isAnalyticsOptedOut = false;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsOptOut();
  }

  Future<void> _loadAnalyticsOptOut() async {
    final analytics = ref.read(analyticsServiceProvider);
    final optedOut = await analytics.isOptedOut();
    if (mounted) setState(() => _isAnalyticsOptedOut = optedOut);
  }

  @override
  Widget build(BuildContext context) {
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
              if (!context.mounted) return;

              final selected = await showDialog<String>(
                context: context,
                builder: (context) => CurrencyPickerDialog(
                  currentCurrency: primaryCurrency,
                ),
              );

              if (selected != null && selected != primaryCurrency) {
                await HapticUtils.medium(); // Setting changed feedback

                ref.read(analyticsServiceProvider).capture('settings_changed', {
                  'setting': 'primary_currency',
                });

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
                  if (!context.mounted) return;

                  final time = await showTimePicker(
                    context: context,
                    initialTime: defaultReminderTime,
                  );

                  if (time != null) {
                    await HapticUtils.medium(); // Setting changed feedback

                    ref.read(analyticsServiceProvider).capture('settings_changed', {
                      'setting': 'reminder_time',
                    });

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

          // Premium section
          const _SectionHeader(title: 'Premium'),
          Consumer(
            builder: (context, ref, child) {
              final isPremiumAsync = ref.watch(isPremiumProvider);

              return isPremiumAsync.when(
                data: (isPremium) => Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        isPremium ? Icons.workspace_premium : Icons.lock_outline,
                        color: isPremium ? AppColors.primary : AppColors.textSecondary,
                      ),
                      title: Text(isPremium ? 'Premium Active' : 'Free Tier'),
                      subtitle: Text(
                        isPremium
                            ? 'Unlimited subscriptions'
                            : '${RevenueCatConstants.maxFreeSubscriptions} subscriptions limit',
                      ),
                      trailing: isPremium ? null : const Icon(Icons.chevron_right),
                      onTap: isPremium
                          ? null
                          : () async {
                              await HapticUtils.light();
                              ref.read(analyticsServiceProvider).capture(
                                'paywall_viewed',
                                {'source': 'settings'},
                              );
                              if (context.mounted) {
                                context.push('/paywall');
                              }
                            },
                    ),
                    if (isPremium)
                      ListTile(
                        leading: const Icon(Icons.restore),
                        title: const Text('Restore Purchases'),
                        subtitle: const Text('Restore premium subscription'),
                        onTap: () async {
                          await HapticUtils.light();

                          // Show loading indicator
                          if (context.mounted) {
                            SnackBarUtils.show(
                              context,
                              SnackBarUtils.info('Restoring purchases...'),
                            );
                          }

                          // Restore purchases
                          final service = ref.read(entitlementServiceProvider);
                          final restored = await service.restorePurchases();

                          if (context.mounted) {
                            SnackBarUtils.show(
                              context,
                              restored
                                  ? SnackBarUtils.success('Purchases restored successfully')
                                  : SnackBarUtils.warning('No purchases to restore'),
                            );
                          }

                          // Refresh premium status
                          ref.invalidate(isPremiumProvider);
                        },
                      ),
                  ],
                ),
                loading: () => const ListTile(
                  leading: Icon(Icons.workspace_premium),
                  title: Text('Loading...'),
                  subtitle: Text('Checking premium status'),
                ),
                error: (err, stack) => ListTile(
                  leading: const Icon(Icons.error_outline, color: AppColors.error),
                  title: const Text('Error loading premium status'),
                  subtitle: Text('$err'),
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Notifications section
          const _SectionHeader(title: 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Test Notification'),
            subtitle: const Text('Verify reminders are working'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await HapticUtils.medium();
              final notificationService = await ref.read(notificationServiceProvider.future);

              // Android 13+: check before firing a doomed notification
              final enabled = await notificationService.areNotificationsEnabled();

              if (!context.mounted) return;

              if (!enabled) {
                // We know notifications are disabled — skip the test, offer fix
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Notifications Disabled'),
                    content: const Text(
                      'Notifications are currently disabled for CustomSubs. '
                      'Enable them in device settings to receive billing reminders.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Not Now'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await AppSettings.openAppSettings(
                            type: AppSettingsType.notification,
                          );
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                );
                return;
              }

              // Send the test
              await notificationService.showTestNotification();

              if (!context.mounted) return;

              // Follow-up dialog — gives iOS users an escape hatch even though
              // we can't pre-check iOS permissions without a heavier dependency
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Test Sent'),
                  content: const Text(
                    'A test notification was just sent.\n\n'
                    "Don't see it? Notifications may be disabled in your device settings.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await AppSettings.openAppSettings(
                          type: AppSettingsType.notification,
                        );
                      },
                      child: const Text('Open Settings'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Got It'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.base,
              vertical: AppSizes.sm,
            ),
            child: Text(
              'CustomSubs sends reminders at your chosen time before billing dates. '
              'Make sure notifications are enabled in your device settings.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const Divider(height: 1),

          // Privacy section
          const _SectionHeader(title: 'Privacy'),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: const Text('Share Anonymous Usage Data'),
            subtitle: const Text(
              'Helps us improve the app. No personal data is collected.',
            ),
            value: !_isAnalyticsOptedOut,
            onChanged: (value) async {
              final analytics = ref.read(analyticsServiceProvider);
              // Track BEFORE setting opt-out (after opt-out, events are dropped)
              if (!value) {
                analytics.capture('settings_changed', {
                  'setting': 'analytics_opt_out',
                });
              }
              await analytics.setOptOut(!value);
              setState(() => _isAnalyticsOptedOut = !value);
            },
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
                  // Calculate share position origin for iOS before async gap
                  final box = context.findRenderObject() as RenderBox?;
                  final sharePositionOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;

                  await HapticUtils.medium(); // Action trigger feedback

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

                    ref.read(analyticsServiceProvider).capture('backup_exported', {
                      'subscription_count': subscriptions.length,
                    });

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

                ref.read(analyticsServiceProvider).capture('backup_imported', {
                  'imported_count': result.imported,
                  'duplicates_skipped': result.duplicates,
                });

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
              if (!context.mounted) return;

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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.4.6'),
            onTap: _handleVersionTap,
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
          const SizedBox(height: AppSizes.sm),
          const CustomAppsPromoCard(),
          const SizedBox(height: AppSizes.sm),
          const ListTile(
            leading: Icon(Icons.favorite_outline),
            title: Text('Made with love by CustomApps LLC'),
          ),

          // Developer Tools section — hidden until version tile tapped 11 times
          if (_devToolsUnlocked) ...[
            const Divider(height: 1),
            const _SectionHeader(title: 'Developer Tools'),
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: const Text('Load Demo Data'),
              subtitle: const Text('Add 18 sample subscriptions'),
              enabled: !_isLoadingDemo,
              onTap: _handleLoadDemoData,
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: const Text('Clear Demo Data'),
              subtitle: const Text('Remove only demo subscriptions'),
              enabled: !_isLoadingDemo,
              onTap: _handleClearDemoData,
            ),
          ],
        ],
      ),
    );
  }

  /// Handles taps on the version tile. After 11 rapid taps (within 3 seconds
  /// of each other), unlocks the hidden Developer Tools section. Provides
  /// subtle haptic hints starting at 7 taps.
  void _handleVersionTap() async {
    final now = DateTime.now();

    // Reset counter if more than 3 seconds since last tap
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inSeconds > 3) {
      _tapCount = 0;
    }

    _lastTapTime = now;
    _tapCount++;

    if (_tapCount >= 11 && !_devToolsUnlocked) {
      await HapticUtils.heavy();
      setState(() => _devToolsUnlocked = true);
      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.info('Developer tools unlocked'),
        );
      }
    } else if (_tapCount >= 7 && !_devToolsUnlocked) {
      // Subtle hint that something is happening
      await HapticUtils.light();
    }
  }

  /// Loads 18 demo subscriptions tagged with [DEMO] in notes.
  /// Additive — does not remove existing subscriptions.
  Future<void> _handleLoadDemoData() async {
    await HapticUtils.light();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Load Demo Data?'),
        content: const Text(
          'This will add 18 sample subscriptions to your app. '
          'Existing subscriptions will not be affected.\n\n'
          'Demo subscriptions are tagged and can be removed '
          'with "Clear Demo Data".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Load'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoadingDemo = true);

    try {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      final notificationService =
          await ref.read(notificationServiceProvider.future);
      final demoSubs = DemoDataService.generateDemoSubscriptions();

      for (final sub in demoSubs) {
        await repository.upsert(sub);
        // Only schedule notifications for active (non-paused) subs
        if (sub.isActive) {
          await notificationService
              .scheduleNotificationsForSubscription(sub);
        }
      }

      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.success('Loaded ${demoSubs.length} demo subscriptions'),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.error('Failed to load demo data: $e'),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingDemo = false);
    }
  }

  /// Removes only subscriptions tagged with [DEMO] in notes.
  /// Real user subscriptions are not affected.
  Future<void> _handleClearDemoData() async {
    await HapticUtils.light();
    if (!mounted) return;

    final repository = await ref.read(subscriptionRepositoryProvider.future);
    if (!mounted) return;

    final allSubs = repository.getAll();
    final demoSubs =
        allSubs.where(DemoDataService.isDemoSubscription).toList();

    if (demoSubs.isEmpty) {
      SnackBarUtils.show(
        context,
        SnackBarUtils.info('No demo subscriptions found'),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Demo Data?'),
        content: Text(
          'This will remove ${demoSubs.length} demo subscription${demoSubs.length == 1 ? '' : 's'}. '
          'Your real subscriptions will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoadingDemo = true);

    try {
      final notificationService =
          await ref.read(notificationServiceProvider.future);

      for (final sub in demoSubs) {
        await notificationService.cancelNotificationsForSubscription(sub.id);
        await repository.delete(sub.id);
      }

      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.success(
              'Cleared ${demoSubs.length} demo subscription${demoSubs.length == 1 ? '' : 's'}'),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.error('Failed to clear demo data: $e'),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingDemo = false);
    }
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
