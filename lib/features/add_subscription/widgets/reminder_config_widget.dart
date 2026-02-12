import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';

class ReminderConfigWidget extends StatelessWidget {
  final ReminderConfig config;
  final ValueChanged<ReminderConfig> onChanged;

  const ReminderConfigWidget({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First reminder
        _buildReminderDropdown(
          context,
          label: 'First reminder',
          value: config.firstReminderDays,
          onChanged: (days) {
            onChanged(config.copyWith(firstReminderDays: days));
          },
        ),
        const SizedBox(height: AppSizes.base),

        // Second reminder
        _buildReminderDropdown(
          context,
          label: 'Second reminder',
          value: config.secondReminderDays,
          onChanged: (days) {
            onChanged(config.copyWith(secondReminderDays: days));
          },
        ),
        const SizedBox(height: AppSizes.base),

        // Remind on billing day
        SwitchListTile(
          title: const Text('Remind on billing day'),
          value: config.remindOnBillingDay,
          onChanged: (value) async {
            await HapticUtils.selection(); // Switch toggle feedback
            onChanged(config.copyWith(remindOnBillingDay: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSizes.base),

        // Reminder time
        ListTile(
          title: const Text('Reminder time'),
          subtitle: Text(
            '${config.reminderHour.toString().padLeft(2, '0')}:${config.reminderMinute.toString().padLeft(2, '0')}',
          ),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            await HapticUtils.light(); // Time picker tap feedback
            if (!context.mounted) return;

            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: config.reminderHour,
                minute: config.reminderMinute,
              ),
            );

            if (time != null) {
              await HapticUtils.medium(); // Time changed feedback
              onChanged(config.copyWith(
                reminderHour: time.hour,
                reminderMinute: time.minute,
              ));
            }
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildReminderDropdown(
    BuildContext context, {
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    final reminderOptions = [
      0, // Off
      1,
      2,
      3,
      5,
      7,
      10,
      14,
    ];

    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
      ),
      items: reminderOptions.map((days) {
        return DropdownMenuItem(
          value: days,
          child: Text(days == 0
              ? 'Off'
              : '$days day${days == 1 ? '' : 's'} before'),
        );
      }).toList(),
      onChanged: (newValue) async {
        if (newValue != null) {
          await HapticUtils.light(); // Dropdown selection feedback
          onChanged(newValue);
        }
      },
    );
  }
}
