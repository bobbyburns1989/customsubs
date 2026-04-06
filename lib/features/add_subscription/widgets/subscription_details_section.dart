import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';
import 'package:custom_subs/core/widgets/styled_date_field.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/l10n/generated/app_localizations.dart';
import 'package:custom_subs/core/utils/localized_enums.dart';

/// Form section for core subscription details (required fields).
///
/// Contains all required fields for creating/editing a subscription:
/// - Name
/// - Amount + Currency
/// - Billing Cycle
/// - Next Billing Date
/// - Category
///
/// **Usage:**
/// ```dart
/// SubscriptionDetailsSection(
///   nameController: _formState.nameController,
///   amountController: _formState.amountController,
///   currencyCode: _currencyCode,
///   cycle: _cycle,
///   nextBillingDate: _nextBillingDate,
///   category: _category,
///   onCurrencyChanged: (value) => setState(() => _currencyCode = value),
///   onCycleChanged: (value) => setState(() => _cycle = value),
///   onNextBillingDateChanged: (value) => setState(() => _nextBillingDate = value),
///   onCategoryChanged: (value) => setState(() => _category = value),
/// )
/// ```
class SubscriptionDetailsSection extends StatelessWidget {
  /// Controller for subscription name field
  final TextEditingController nameController;

  /// Controller for subscription amount field
  final TextEditingController amountController;

  /// Selected currency code (e.g., 'USD', 'EUR')
  final String currencyCode;

  /// Selected billing cycle
  final SubscriptionCycle cycle;

  /// Next billing date
  final DateTime nextBillingDate;

  /// Selected category
  final SubscriptionCategory category;

  /// Callback when currency is changed
  final ValueChanged<String> onCurrencyChanged;

  /// Callback when billing cycle is changed
  final ValueChanged<SubscriptionCycle> onCycleChanged;

  /// Callback when next billing date is changed
  final ValueChanged<DateTime> onNextBillingDateChanged;

  /// Callback when category is changed
  final ValueChanged<SubscriptionCategory> onCategoryChanged;

  const SubscriptionDetailsSection({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.currencyCode,
    required this.cycle,
    required this.nextBillingDate,
    required this.category,
    required this.onCurrencyChanged,
    required this.onCycleChanged,
    required this.onNextBillingDateChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FormSectionCard(
      title: l10n.detailsSection,
      icon: Icons.edit_outlined,
      isCollapsible: false, // Required fields - always visible
      child: Column(
        children: [
          // Name field
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.detailsNameLabel,
              hintText: l10n.detailsNameHint,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.detailsNameValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.md),

          // Amount and Currency row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: l10n.detailsAmountLabel,
                    hintText: l10n.detailsAmountHint,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.detailsAmountRequired;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return l10n.detailsAmountInvalid;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: currencyCode,
                  decoration: InputDecoration(labelText: l10n.detailsCurrencyLabel),
                  items: CurrencyUtils.getSupportedCurrencies()
                      .map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(code),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onCurrencyChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Billing cycle dropdown
          DropdownButtonFormField<SubscriptionCycle>(
            value: cycle,
            decoration: InputDecoration(labelText: l10n.detailsBillingCycleLabel),
            items: SubscriptionCycle.values
                .map((cycle) => DropdownMenuItem(
                      value: cycle,
                      child: Text(cycle.localizedName(l10n)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onCycleChanged(value);
              }
            },
          ),
          const SizedBox(height: AppSizes.md),

          // Next billing date picker
          StyledDateField(
            label: l10n.detailsNextBillingDateLabel,
            value: nextBillingDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 3650)),
            onChanged: onNextBillingDateChanged,
          ),
          const SizedBox(height: AppSizes.md),

          // Category dropdown
          DropdownButtonFormField<SubscriptionCategory>(
            value: category,
            decoration: InputDecoration(labelText: l10n.detailsCategoryLabel),
            items: SubscriptionCategory.values
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text('${cat.icon} ${cat.localizedName(l10n)}'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
