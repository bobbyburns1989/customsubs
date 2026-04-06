import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';
import 'package:custom_subs/core/widgets/styled_date_field.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';

/// Form section for free trial configuration.
///
/// Provides a collapsible section with:
/// - Trial toggle switch
/// - Trial end date picker (conditional)
/// - Post-trial amount field (conditional)
///
/// Fields are shown/hidden with AnimatedSize based on trial toggle state.
///
/// **Usage:**
/// ```dart
/// TrialSection(
///   isTrial: _isTrial,
///   trialEndDate: _trialEndDate,
///   postTrialAmount: _postTrialAmount,
///   onTrialChanged: (value) => setState(() => _isTrial = value),
///   onTrialEndDateChanged: (value) => setState(() => _trialEndDate = value),
///   onPostTrialAmountChanged: (value) => setState(() => _postTrialAmount = value),
///   onSetTrialEndDate: () => setState(() => _trialEndDate = DateTime.now().add(Duration(days: 7))),
/// )
/// ```
class TrialSection extends StatelessWidget {
  /// Whether the subscription is currently in a trial period
  final bool isTrial;

  /// Trial end date (null if not set yet)
  final DateTime? trialEndDate;

  /// Amount to charge after trial ends
  final double? postTrialAmount;

  /// Callback when trial toggle is changed
  final ValueChanged<bool> onTrialChanged;

  /// Callback when trial end date is changed
  final ValueChanged<DateTime> onTrialEndDateChanged;

  /// Callback when post-trial amount is changed
  final ValueChanged<double?> onPostTrialAmountChanged;

  /// Callback when user wants to set trial end date for first time
  final VoidCallback onSetTrialEndDate;

  const TrialSection({
    super.key,
    required this.isTrial,
    required this.trialEndDate,
    required this.postTrialAmount,
    required this.onTrialChanged,
    required this.onTrialEndDateChanged,
    required this.onPostTrialAmountChanged,
    required this.onSetTrialEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FormSectionCard(
      title: l10n.trialSectionTitle,
      subtitle: l10n.trialSectionSubtitle,
      icon: Icons.timer_outlined,
      isCollapsible: true,
      initiallyExpanded: false,
      child: Column(
        children: [
          // Trial toggle
          SwitchListTile(
            title: Text(l10n.trialToggleLabel),
            subtitle: Text(l10n.trialToggleSubtitle),
            value: isTrial,
            onChanged: onTrialChanged,
            contentPadding: EdgeInsets.zero,
          ),

          // Animated trial fields (shown only when isTrial is true)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isTrial
                ? Column(
                    children: [
                      const SizedBox(height: AppSizes.md),

                      // Trial end date picker or set button
                      if (trialEndDate != null)
                        StyledDateField(
                          label: l10n.trialEndDateLabel,
                          value: trialEndDate!,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          onChanged: onTrialEndDateChanged,
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: onSetTrialEndDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(l10n.trialSetEndDate),
                        ),

                      const SizedBox(height: AppSizes.md),

                      // Post-trial amount field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n.trialAmountAfter,
                          hintText: l10n.detailsAmountHint,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        initialValue: postTrialAmount?.toString(),
                        onChanged: (value) {
                          onPostTrialAmountChanged(double.tryParse(value));
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
