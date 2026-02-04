import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/data/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // General section
          _SectionHeader(title: 'General'),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Primary Currency'),
            subtitle: const Text('USD'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement currency picker
            },
          ),

          const Divider(height: 1),

          // Notifications section
          _SectionHeader(title: 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification now'),
            onTap: () async {
              final notificationService = await ref.read(notificationServiceProvider.future);
              await notificationService.showTestNotification();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),

          const Divider(height: 1),

          // Data section
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Backup'),
            subtitle: const Text('Save your subscriptions to a file'),
            onTap: () {
              // TODO: Implement export
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Backup'),
            subtitle: const Text('Restore subscriptions from a file'),
            onTap: () {
              // TODO: Implement import
            },
          ),

          const Divider(height: 1),

          // About section
          _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.favorite_outline),
            title: Text('Made with ♥ by Custom*'),
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
