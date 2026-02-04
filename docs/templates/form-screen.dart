// TEMPLATE: Form Screen with Local State
//
// This is a fully annotated example of a form screen pattern.
// Copy and modify for form-based features (Add/Edit flows).
//
// This example shows adding/editing a subscription.
//
// **Pattern**: Forms typically use ConsumerStatefulWidget + local state,
// NOT a Riverpod controller. Controllers are for screen-level app state,
// not transient form state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/data/repositories/subscription_repository.dart';
import 'package:custom_subs/data/services/notification_service.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:uuid/uuid.dart';

/// Add or edit a subscription form.
///
/// **Pattern**: Use ConsumerStatefulWidget for forms because:
/// - Form state is transient (only exists during editing)
/// - TextEditingControllers work well with StatefulWidget
/// - No need for Riverpod controller overhead
/// - Use Riverpod only for repository access
///
/// **When to use ConsumerWidget instead**:
/// - No form state (just buttons/navigation)
/// - No TextEditingControllers needed
/// - No local animations/focus management
class AddSubscriptionScreen extends ConsumerStatefulWidget {
  /// Optional subscription ID for edit mode.
  /// If null, we're creating a new subscription.
  final String? subscriptionId;

  const AddSubscriptionScreen({
    super.key,
    this.subscriptionId,
  });

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  // ========================================================================
  // FORM STATE - Local to this screen only
  // ========================================================================

  /// Form key for validation.
  /// **Required** for form validation to work.
  final _formKey = GlobalKey<FormState>();

  // Text controllers for inputs
  /// **Important**: Always dispose() controllers to prevent memory leaks.
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  // Dropdown/picker selections
  /// Store selected values as local state variables.
  SubscriptionCycle _selectedCycle = SubscriptionCycle.monthly;
  SubscriptionCategory _selectedCategory = SubscriptionCategory.entertainment;
  String _selectedCurrency = 'USD';
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));

  // Trial mode state
  bool _isTrial = false;
  DateTime? _trialEndDate;
  double? _postTrialAmount;

  // Loading state for async operations
  /// **Pattern**: Use local loading state for save/submit operations.
  bool _isSaving = false;

  // ========================================================================
  // LIFECYCLE METHODS
  // ========================================================================

  @override
  void initState() {
    super.initState();

    // Load existing subscription data if editing
    if (widget.subscriptionId != null) {
      _loadSubscription();
    }
  }

  @override
  void dispose() {
    // **CRITICAL**: Dispose all controllers to prevent memory leaks.
    // This is called when the widget is removed from the tree.
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ========================================================================
  // DATA LOADING (Edit mode only)
  // ========================================================================

  /// Loads existing subscription data for editing.
  ///
  /// **Pattern**: Load data in initState() and populate controllers.
  /// Use ref.read() for one-time data access.
  Future<void> _loadSubscription() async {
    try {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      final subscription = repository.getById(widget.subscriptionId!);

      if (subscription == null) {
        // Subscription not found - navigate back
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription not found')),
          );
        }
        return;
      }

      // Populate form with existing data
      // **Use setState()** to update local state variables
      setState(() {
        _nameController.text = subscription.name;
        _amountController.text = subscription.amount.toString();
        _selectedCycle = subscription.cycle;
        _selectedCategory = subscription.category;
        _selectedCurrency = subscription.currencyCode;
        _nextBillingDate = subscription.nextBillingDate;
        _isTrial = subscription.isTrial;
        _trialEndDate = subscription.trialEndDate;
        _postTrialAmount = subscription.postTrialAmount;
        _notesController.text = subscription.notes ?? '';
      });
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subscription: $e')),
        );
      }
    }
  }

  // ========================================================================
  // FORM SUBMISSION
  // ========================================================================

  /// Validates and saves the subscription.
  ///
  /// **Pattern**: Form submission should:
  /// 1. Validate input
  /// 2. Show loading state
  /// 3. Save to repository
  /// 4. Trigger side effects (notifications)
  /// 5. Navigate back on success
  /// 6. Show error on failure
  Future<void> _saveSubscription() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      // Validation failed - show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors above')),
      );
      return;
    }

    // Show loading state
    setState(() {
      _isSaving = true;
    });

    try {
      // Build subscription object
      final subscription = _buildSubscription();

      // Save to repository
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      await repository.upsert(subscription);

      // Schedule notifications
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.scheduleNotificationsForSubscription(subscription);

      // Navigate back on success
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.subscriptionId == null
                  ? 'Subscription added!'
                  : 'Subscription updated!',
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  /// Builds a Subscription object from form state.
  ///
  /// **Pattern**: Extract object construction to separate method for clarity.
  Subscription _buildSubscription() {
    return Subscription(
      id: widget.subscriptionId ?? const Uuid().v4(), // Use existing ID or generate new
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      currencyCode: _selectedCurrency,
      cycle: _selectedCycle,
      nextBillingDate: _nextBillingDate,
      startDate: widget.subscriptionId == null
          ? DateTime.now()
          : DateTime.now(), // TODO: Load from existing subscription
      category: _selectedCategory,
      colorValue: AppColors.subscriptionColors[0].value, // TODO: Add color picker
      reminders: ReminderConfig(), // Default reminder config
      isTrial: _isTrial,
      trialEndDate: _trialEndDate,
      postTrialAmount: _postTrialAmount,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }

  // ========================================================================
  // BUILD METHOD - UI Layout
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ====================================================================
      // APP BAR
      // ====================================================================
      appBar: AppBar(
        title: Text(
          widget.subscriptionId == null ? 'Add Subscription' : 'Edit Subscription',
        ),
        actions: [
          // Save button in app bar
          if (!_isSaving)
            TextButton(
              onPressed: _saveSubscription,
              child: const Text('Save'),
            ),
        ],
      ),

      // ====================================================================
      // BODY - Form with ScrollView
      // ====================================================================
      body: Form(
        key: _formKey, // Required for validation
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.base),
          children: [
            // ================================================================
            // NAME FIELD
            // ================================================================
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Netflix',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
              // **Validation**: Required field
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null; // Valid
              },
            ),
            const SizedBox(height: AppSizes.base),

            // ================================================================
            // AMOUNT FIELD
            // ================================================================
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '15.99',
                prefixIcon: const Icon(Icons.attach_money),
                prefixText: _getCurrencySymbol(_selectedCurrency),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              // **Input formatters**: Only allow numbers and decimal point
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              // **Validation**: Required, must be positive number
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid number';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null; // Valid
              },
            ),
            const SizedBox(height: AppSizes.base),

            // ================================================================
            // CURRENCY DROPDOWN
            // ================================================================
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              items: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
                  .map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppSizes.base),

            // ================================================================
            // BILLING CYCLE DROPDOWN
            // ================================================================
            DropdownButtonFormField<SubscriptionCycle>(
              value: _selectedCycle,
              decoration: const InputDecoration(
                labelText: 'Billing Cycle',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              items: SubscriptionCycle.values
                  .map((cycle) => DropdownMenuItem(
                        value: cycle,
                        child: Text(cycle.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCycle = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppSizes.base),

            // ================================================================
            // NEXT BILLING DATE PICKER
            // ================================================================
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Next Billing Date'),
              subtitle: Text(
                _nextBillingDate.toLocal().toString().split(' ')[0],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _nextBillingDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (pickedDate != null) {
                  setState(() {
                    _nextBillingDate = pickedDate;
                  });
                }
              },
            ),
            const Divider(),

            // ================================================================
            // CATEGORY DROPDOWN
            // ================================================================
            DropdownButtonFormField<SubscriptionCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: SubscriptionCategory.values
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppSizes.base),

            // ================================================================
            // FREE TRIAL TOGGLE
            // ================================================================
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Free Trial'),
              subtitle: const Text('This subscription is currently in a free trial'),
              value: _isTrial,
              onChanged: (value) {
                setState(() {
                  _isTrial = value;
                  if (!value) {
                    // Clear trial data when disabled
                    _trialEndDate = null;
                    _postTrialAmount = null;
                  }
                });
              },
            ),

            // Trial-specific fields (only show if trial enabled)
            if (_isTrial) ...[
              const SizedBox(height: AppSizes.base),
              // Trial end date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy),
                title: const Text('Trial End Date'),
                subtitle: Text(
                  _trialEndDate?.toLocal().toString().split(' ')[0] ?? 'Not set',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _trialEndDate ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _trialEndDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSizes.base),
              // Post-trial amount
              TextFormField(
                initialValue: _postTrialAmount?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Amount After Trial',
                  hintText: 'Amount charged after trial ends',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  _postTrialAmount = double.tryParse(value);
                },
              ),
            ],

            const SizedBox(height: AppSizes.base),

            // ================================================================
            // NOTES FIELD (Optional)
            // ================================================================
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional notes',
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: AppSizes.xxl),

            // ================================================================
            // SAVE BUTTON (Bottom of form)
            // ================================================================
            ElevatedButton(
              onPressed: _isSaving ? null : _saveSubscription,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.base),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.subscriptionId == null
                          ? 'Add Subscription'
                          : 'Save Changes',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Gets currency symbol for display.
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currencyCode;
    }
  }
}

// ============================================================================
// KEY PATTERNS DEMONSTRATED
// ============================================================================
//
// 1. **ConsumerStatefulWidget Pattern**
//    - Use for forms with local state
//    - TextEditingControllers for input fields
//    - setState() for updating local state
//
// 2. **Form Validation**
//    - GlobalKey<FormState> for form key
//    - validator: callbacks on TextFormField
//    - _formKey.currentState!.validate() to trigger
//
// 3. **Lifecycle Management**
//    - initState() to load data for edit mode
//    - dispose() to clean up controllers (CRITICAL!)
//
// 4. **Loading States**
//    - _isSaving boolean for async operations
//    - Show spinner in button during save
//    - Disable button while saving
//
// 5. **Navigation**
//    - Navigator.pop() to go back
//    - ScaffoldMessenger for snackbars
//    - Check mounted before navigation
//
// 6. **Riverpod Usage**
//    - ref.read() for one-time repository access
//    - No controller needed for transient form state
//
// 7. **Input Validation**
//    - Required fields
//    - Number validation
//    - Custom validation logic
//    - InputFormatters for input restrictions
//
// 8. **Conditional UI**
//    - Show/hide trial fields based on toggle
//    - Different labels for create vs edit mode
//
// ============================================================================
// CUSTOMIZATION CHECKLIST
// ============================================================================
//
// To adapt this template for your form:
//
// [ ] Replace Subscription with your model
// [ ] Add/remove form fields as needed
// [ ] Update validation rules for your requirements
// [ ] Customize InputFormatters if needed
// [ ] Add color picker, image picker, etc. if needed
// [ ] Update _build[Model]() method
// [ ] Update _save() method with your repository calls
// [ ] Add any additional side effects (notifications, etc.)
// [ ] Update empty/default values
// [ ] Test validation edge cases
// [ ] Test edit mode (loading existing data)
// [ ] Ensure all controllers are disposed
//
// ============================================================================
