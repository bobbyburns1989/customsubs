import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/extensions/theme_extensions.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';
import 'package:custom_subs/core/providers/settings_provider.dart';
import 'package:custom_subs/core/providers/theme_provider.dart';
import 'package:custom_subs/core/providers/locale_provider.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/data/services/backup_service.dart';
import 'package:custom_subs/data/services/undo_service.dart';
import 'package:custom_subs/data/services/demo_data_service.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/features/settings/widgets/currency_picker_dialog.dart';
import 'package:custom_subs/features/settings/widgets/compact_action_buttons.dart';
import 'package:custom_subs/features/settings/widgets/custom_apps_promo_card.dart';
import 'package:custom_subs/data/services/analytics_service.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
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
          // Share, Rate, Feedback action buttons
          const CompactActionButtons(),

          // General section
          _SectionHeader(title: l10n.settingsGeneral),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(l10n.settingsPrimaryCurrency),
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
                      l10n.settingsCurrencyChanged(selected),
                      onUndo: () async {
                        await HapticUtils.medium();
                        final previous = undoService.getPreviousCurrency();
                        if (previous != null) {
                          await ref.read(settingsRepositoryProvider.notifier)
                              .setPrimaryCurrency(previous);
                          if (context.mounted) {
                            SnackBarUtils.show(
                              context,
                              SnackBarUtils.info(l10n.settingsCurrencyRestored(previous)),
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
              final l10n = AppLocalizations.of(context);
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
                title: Text(l10n.settingsDefaultReminderTime),
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
                          l10n.settingsReminderTimeUpdated,
                          onUndo: () async {
                            await HapticUtils.medium();
                            final previous = undoService.getPreviousReminderTime();
                            if (previous != null) {
                              await ref.read(settingsRepositoryProvider.notifier)
                                  .setDefaultReminderTime(previous.hour, previous.minute);
                              if (context.mounted) {
                                SnackBarUtils.show(
                                  context,
                                  SnackBarUtils.info(l10n.settingsReminderTimeRestored),
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
          Consumer(
            builder: (context, ref, child) {
              final l10n = AppLocalizations.of(context);
              final themeMode = ref.watch(themeModeProvider);
              final isDarkMode = themeMode == ThemeMode.dark;

              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.settingsDarkMode),
                value: isDarkMode,
                onChanged: (value) async {
                  await HapticUtils.medium();
                  await ref.read(settingsRepositoryProvider.notifier)
                      .setIsDarkMode(value);

                  ref.read(analyticsServiceProvider).capture('settings_changed', {
                    'setting': 'dark_mode',
                  });
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            trailing: Text(_getLanguageLabel(l10n)),
            onTap: () => _showLanguagePicker(context, ref, l10n),
          ),

          const Divider(height: 1),

          // Notifications section
          _SectionHeader(title: l10n.settingsNotifications),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsTestNotification),
            subtitle: Text(l10n.settingsTestNotificationSubtitle),
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
                    title: Text(l10n.settingsNotificationsDisabled),
                    content: Text(l10n.settingsNotificationsDisabledBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(l10n.settingsNotNow),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await AppSettings.openAppSettings(
                            type: AppSettingsType.notification,
                          );
                        },
                        child: Text(l10n.settingsOpenSettings),
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
                  title: Text(l10n.settingsTestSent),
                  content: Text(l10n.settingsTestSentBody),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await AppSettings.openAppSettings(
                          type: AppSettingsType.notification,
                        );
                      },
                      child: Text(l10n.settingsOpenSettings),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.settingsGotIt),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.base,
              vertical: AppSizes.sm,
            ),
            child: Text(
              l10n.settingsNotificationsHelp,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),

          const Divider(height: 1),

          // Privacy section
          _SectionHeader(title: l10n.settingsPrivacy),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: Text(l10n.settingsShareAnalytics),
            subtitle: Text(l10n.settingsShareAnalyticsSubtitle),
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
          _SectionHeader(title: l10n.settingsData),
          Consumer(
            builder: (context, ref, child) {
              final l10n = AppLocalizations.of(context);
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
                title: Text(l10n.settingsLastBackup),
                subtitle: Text(
                  lastBackupDate != null
                      ? _formatBackupDate(lastBackupDate)
                      : l10n.settingsNeverBackedUp,
                  style: TextStyle(
                    color: lastBackupDate == null ? context.colors.warning : null,
                    fontWeight:
                        lastBackupDate == null ? FontWeight.w600 : null,
                  ),
                ),
              );
            },
          ),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(l10n.settingsExportBackup),
                subtitle: Text(l10n.settingsExportBackupSubtitle),
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
                        SnackBarUtils.info(l10n.settingsPreparingBackup),
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
                        SnackBarUtils.success(l10n.settingsBackupSuccess),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      SnackBarUtils.show(
                        context,
                        SnackBarUtils.error(l10n.settingsBackupError(e.toString())),
                      );
                    }
                  }
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.settingsImportBackup),
            subtitle: Text(l10n.settingsImportBackupSubtitle),
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
                      title: Text(l10n.settingsImportComplete),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.settingsImportFound(result.totalFound)),
                          Text(l10n.settingsImportDuplicates(result.duplicates)),
                          Text(l10n.settingsImportImported(result.imported)),
                          if (result.hasWarnings) ...[
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              l10n.settingsImportSkipped(result.skippedCount),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.warning,
                              ),
                            ),
                          ],
                          if (result.imported > 0) ...[
                            const SizedBox(height: AppSizes.base),
                            Text(
                              l10n.settingsImportNotifications,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.settingsOk),
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
                    SnackBarUtils.error(l10n.settingsBackupError(e.toString())),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: context.colors.error),
            title: Text(
              l10n.settingsDeleteAll,
              style: TextStyle(color: context.colors.error),
            ),
            subtitle: Text(l10n.settingsDeleteAllSubtitle),
            onTap: () async {
              await HapticUtils.light(); // ListTile tap feedback
              if (!context.mounted) return;

              // First confirmation
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.settingsDeleteAllTitle),
                  content: Text(l10n.settingsDeleteAllBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.settingsCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.error,
                      ),
                      child: Text(l10n.settingsContinue),
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
                  title: Text(l10n.settingsFinalConfirmation),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsFinalConfirmationBody,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.base),
                      Text(l10n.settingsTypeDelete),
                      const SizedBox(height: AppSizes.sm),
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: l10n.settingsDeleteHint,
                          border: const OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.settingsCancel),
                    ),
                    TextButton(
                      onPressed: () {
                        if (textController.text == 'DELETE') {
                          Navigator.pop(context, true);
                        } else {
                          SnackBarUtils.show(
                            context,
                            SnackBarUtils.warning(l10n.settingsTypeDeleteWarning),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.error,
                      ),
                      child: Text(l10n.settingsDeleteButton),
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
                    SnackBarUtils.warning(l10n.settingsAllDataDeleted),
                  );

                  // Pop back to home
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarUtils.show(
                    context,
                    SnackBarUtils.error(l10n.settingsDeleteError(e.toString())),
                  );
                }
              }
            },
          ),

          const Divider(height: 1),

          // About section
          _SectionHeader(title: l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsVersion),
            subtitle: const Text('1.4.6'),
            onTap: _handleVersionTap,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacyPolicy),
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
            title: Text(l10n.settingsTermsOfService),
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
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: Text(l10n.settingsMadeWith),
          ),

          // Developer Tools section — hidden until version tile tapped 11 times
          if (_devToolsUnlocked) ...[
            const Divider(height: 1),
            _SectionHeader(title: l10n.settingsDeveloperTools),
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: Text(l10n.settingsLoadDemoData),
              subtitle: Text(l10n.settingsLoadDemoDataSubtitle),
              enabled: !_isLoadingDemo,
              onTap: _handleLoadDemoData,
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(l10n.settingsClearDemoData),
              subtitle: Text(l10n.settingsClearDemoDataSubtitle),
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
        final l10n = AppLocalizations.of(context);
        SnackBarUtils.show(
          context,
          SnackBarUtils.info(l10n.settingsDeveloperUnlocked),
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

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsLoadDemoTitle),
        content: Text(l10n.settingsLoadDemoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.settingsLoad),
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
          SnackBarUtils.success(l10n.settingsLoadedDemoCount(demoSubs.length)),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.error(l10n.settingsLoadDemoError(e.toString())),
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

    final l10n = AppLocalizations.of(context);
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    if (!mounted) return;

    final allSubs = repository.getAll();
    final demoSubs =
        allSubs.where(DemoDataService.isDemoSubscription).toList();

    if (demoSubs.isEmpty) {
      SnackBarUtils.show(
        context,
        SnackBarUtils.info(l10n.settingsNoDemoFound),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsClearDemoTitle),
        content: Text(l10n.settingsClearDemoBody(demoSubs.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text(l10n.settingsClear),
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
          SnackBarUtils.success(l10n.settingsClearedDemoCount(demoSubs.length)),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.show(
          context,
          SnackBarUtils.error(l10n.settingsClearDemoError(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingDemo = false);
    }
  }

  /// Returns the display label for the currently selected language.
  String _getLanguageLabel(AppLocalizations l10n) {
    final locale = ref.watch(appLocaleProvider);
    if (locale == null) return l10n.settingsLanguageSystem;
    switch (locale.languageCode) {
      case 'en':
        return l10n.settingsLanguageEnglish;
      case 'fr':
        return l10n.settingsLanguageFrench;
      case 'es':
        return l10n.settingsLanguageSpanish;
      default:
        return l10n.settingsLanguageSystem;
    }
  }

  /// Shows a bottom sheet / dialog for choosing a language.
  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    await HapticUtils.light();
    if (!context.mounted) return;

    final currentLocale = ref.read(appLocaleProvider);
    final currentCode = currentLocale?.languageCode;

    final selected = await showDialog<String?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: [
          _buildLanguageOption(ctx, l10n.settingsLanguageSystem, null, currentCode),
          _buildLanguageOption(ctx, l10n.settingsLanguageEnglish, 'en', currentCode),
          _buildLanguageOption(ctx, l10n.settingsLanguageFrench, 'fr', currentCode),
          _buildLanguageOption(ctx, l10n.settingsLanguageSpanish, 'es', currentCode),
        ],
      ),
    );

    // selected is the language code, or 'system' for system default
    // null means dialog was dismissed without selection
    if (selected == null) return;

    await HapticUtils.medium();
    final code = selected == 'system' ? null : selected;
    await ref.read(settingsRepositoryProvider.notifier).setAppLocale(code);

    ref.read(analyticsServiceProvider).capture('settings_changed', {
      'setting': 'language',
    });
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String? code,
    String? currentCode,
  ) {
    final isSelected = code == currentCode;
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, code ?? 'system'),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (isSelected) const Icon(Icons.check, size: 20),
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
