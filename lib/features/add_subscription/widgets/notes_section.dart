import 'package:flutter/material.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return FormSectionCard(
      title: l10n.notesSectionTitle,
      subtitle: l10n.notesSectionSubtitle,
      icon: Icons.note_outlined,
      isCollapsible: true,
      initiallyExpanded: false,
      child: TextFormField(
        controller: notesController,
        decoration: InputDecoration(
          labelText: l10n.notesGeneralLabel,
          hintText: l10n.notesGeneralHint,
        ),
        maxLines: 4,
      ),
    );
  }
}
