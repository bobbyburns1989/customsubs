import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';

/// Form section for cancellation information and checklist.
///
/// Provides fields for cancellation URL, phone, and notes, plus a dynamic
/// checklist builder for step-by-step cancellation instructions.
///
/// **Usage:**
/// ```dart
/// CancellationSection(
///   cancelUrlController: _cancelUrlController,
///   cancelPhoneController: _cancelPhoneController,
///   cancelNotesController: _cancelNotesController,
///   cancelChecklist: _cancelChecklist,
///   onChecklistChanged: (newList) => setState(() => _cancelChecklist = newList),
/// )
/// ```
class CancellationSection extends StatelessWidget {
  /// Controller for cancellation URL field
  final TextEditingController cancelUrlController;

  /// Controller for cancellation phone field
  final TextEditingController cancelPhoneController;

  /// Controller for cancellation notes field
  final TextEditingController cancelNotesController;

  /// List of cancellation checklist steps
  final List<String> cancelChecklist;

  /// Callback when checklist is modified (add/edit/delete)
  final ValueChanged<List<String>> onChecklistChanged;

  const CancellationSection({
    super.key,
    required this.cancelUrlController,
    required this.cancelPhoneController,
    required this.cancelNotesController,
    required this.cancelChecklist,
    required this.onChecklistChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormSectionCard(
      title: 'Cancellation Info',
      subtitle: 'How to cancel this subscription',
      icon: Icons.exit_to_app_outlined,
      isCollapsible: true,
      initiallyExpanded: false,
      child: Column(
        children: [
          TextFormField(
            controller: cancelUrlController,
            decoration: const InputDecoration(
              labelText: 'Cancellation URL',
              hintText: 'https://...',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: cancelPhoneController,
            decoration: const InputDecoration(
              labelText: 'Cancellation Phone',
              hintText: '+1 (555) 123-4567',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: cancelNotesController,
            decoration: const InputDecoration(
              labelText: 'Cancellation Notes',
              hintText: 'How to cancel...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.md),

          // Cancellation Checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cancellation Steps',
                style: theme.textTheme.titleSmall,
              ),
              TextButton.icon(
                onPressed: () {
                  final newList = List<String>.from(cancelChecklist)..add('');
                  onChecklistChanged(newList);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
              ),
            ],
          ),
          ...cancelChecklist.asMap().entries.map((entry) {
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: entry.value,
                      decoration: InputDecoration(
                        labelText: 'Step ${index + 1}',
                        hintText: 'Enter step...',
                      ),
                      onChanged: (value) {
                        final newList = List<String>.from(cancelChecklist);
                        newList[index] = value;
                        onChecklistChanged(newList);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      final newList = List<String>.from(cancelChecklist)..removeAt(index);
                      onChecklistChanged(newList);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
