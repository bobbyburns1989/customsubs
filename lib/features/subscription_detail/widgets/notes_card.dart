import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// A simple card displaying user-entered notes for a subscription.
///
/// Used to display general notes/reminders that don't fit into other
/// structured fields (cancellation info, billing details, etc.).
///
/// ## Usage
///
/// ```dart
/// // Display notes in detail screen
/// if (subscription.notes != null && subscription.notes!.isNotEmpty)
///   NotesCard(notes: subscription.notes!)
/// ```
///
/// ## Design Philosophy
///
/// This widget provides a clean, consistent card format for free-form text.
/// Notes are displayed at body medium size for easy readability. The card
/// uses standard padding and matches other detail screen cards.
///
/// ## Conditional Rendering
///
/// This card should only be shown when notes exist and are non-empty:
/// ```dart
/// if (subscription.notes != null && subscription.notes!.isNotEmpty)
///   NotesCard(notes: subscription.notes!)
/// ```
class NotesCard extends StatelessWidget {
  /// The notes text to display
  final String notes;

  const NotesCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.base),
            Text(
              notes,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
