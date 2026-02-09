import 'package:flutter/material.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';

/// Form section for general notes field.
///
/// Provides a collapsible section with a multiline text field for
/// users to add any additional notes about the subscription.
///
/// **Usage:**
/// ```dart
/// NotesSection(
///   notesController: _formState.notesController,
/// )
/// ```
class NotesSection extends StatelessWidget {
  /// Controller for the notes text field
  final TextEditingController notesController;

  const NotesSection({
    super.key,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Notes',
      subtitle: 'Add any additional notes',
      icon: Icons.note_outlined,
      isCollapsible: true,
      initiallyExpanded: false,
      child: TextFormField(
        controller: notesController,
        decoration: const InputDecoration(
          labelText: 'General Notes',
          hintText: 'Add any additional notes...',
        ),
        maxLines: 4,
      ),
    );
  }
}
