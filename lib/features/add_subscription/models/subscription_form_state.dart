import 'package:flutter/material.dart';
import 'package:custom_subs/data/models/subscription.dart';
import 'package:custom_subs/data/services/template_service.dart';

/// Manages all TextEditingControllers and form state for AddSubscriptionScreen.
///
/// **Responsibilities:**
/// - Initialize and dispose all TextEditingControllers
/// - Validate form data
/// - Collect form data into a structured format
/// - Support both create and edit modes
///
/// **Usage Example:**
/// ```dart
/// final formState = SubscriptionFormState();
///
/// // Load existing data (edit mode)
/// formState.loadFromSubscription(subscription);
///
/// // Access controllers
/// TextField(controller: formState.nameController)
///
/// // Validate
/// if (!formState.validate()) return;
///
/// // Get data
/// final data = formState.toFormData();
///
/// // Dispose when done
/// formState.dispose();
/// ```
class SubscriptionFormState {
  /// Controller for subscription name field
  final nameController = TextEditingController();

  /// Controller for subscription amount field
  final amountController = TextEditingController();

  /// Controller for cancellation URL field
  final cancelUrlController = TextEditingController();

  /// Controller for cancellation phone field
  final cancelPhoneController = TextEditingController();

  /// Controller for cancellation notes field
  final cancelNotesController = TextEditingController();

  /// Controller for general notes field
  final notesController = TextEditingController();

  /// Controller for template search field
  final searchController = TextEditingController();

  /// Creates a new instance of SubscriptionFormState with initialized controllers
  SubscriptionFormState();

  /// Loads form data from an existing subscription (edit mode).
  ///
  /// Populates all text controllers with values from the subscription.
  /// Empty/null fields are set to empty strings.
  ///
  /// **Example:**
  /// ```dart
  /// final subscription = await repository.getById(id);
  /// formState.loadFromSubscription(subscription);
  /// ```
  void loadFromSubscription(Subscription subscription) {
    nameController.text = subscription.name;
    amountController.text = subscription.amount.toString();
    cancelUrlController.text = subscription.cancelUrl ?? '';
    cancelPhoneController.text = subscription.cancelPhone ?? '';
    cancelNotesController.text = subscription.cancelNotes ?? '';
    notesController.text = subscription.notes ?? '';
  }

  /// Loads form data from a subscription template.
  ///
  /// Pre-fills name, amount, and cancel URL (if available) from the template.
  /// Used when user selects a template from the template picker.
  ///
  /// **Example:**
  /// ```dart
  /// final template = templates.firstWhere((t) => t.id == 'netflix');
  /// formState.loadFromTemplate(template);
  /// ```
  void loadFromTemplate(SubscriptionTemplate template) {
    nameController.text = template.name;
    amountController.text = template.defaultAmount.toString();
    if (template.cancelUrl != null) {
      cancelUrlController.text = template.cancelUrl!;
    }
  }

  /// Validates all required form fields.
  ///
  /// **Validation Rules:**
  /// - Name: Must not be empty (after trimming)
  /// - Amount: Must be a valid positive number
  ///
  /// **Returns:**
  /// `true` if all validations pass, `false` otherwise.
  ///
  /// **Example:**
  /// ```dart
  /// if (!formState.validate()) {
  ///   showSnackBar('Please enter valid data');
  ///   return;
  /// }
  /// ```
  bool validate() {
    // Name is required
    if (nameController.text.trim().isEmpty) {
      return false;
    }

    // Amount must be a valid positive number
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      return false;
    }

    return true;
  }

  /// Collects all form data into a structured [SubscriptionFormData] object.
  ///
  /// Trims all text fields and converts empty strings to null for optional fields.
  /// Use this method after validation to get clean data for saving.
  ///
  /// **Example:**
  /// ```dart
  /// if (formState.validate()) {
  ///   final data = formState.toFormData();
  ///   await controller.saveSubscription(
  ///     name: data.name,
  ///     amount: data.amount,
  ///     cancelUrl: data.cancelUrl,
  ///     // ...
  ///   );
  /// }
  /// ```
  SubscriptionFormData toFormData() {
    return SubscriptionFormData(
      name: nameController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
      cancelUrl: cancelUrlController.text.trim().isEmpty
          ? null
          : cancelUrlController.text.trim(),
      cancelPhone: cancelPhoneController.text.trim().isEmpty
          ? null
          : cancelPhoneController.text.trim(),
      cancelNotes: cancelNotesController.text.trim().isEmpty
          ? null
          : cancelNotesController.text.trim(),
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );
  }

  /// Clears all text controllers.
  ///
  /// Useful for resetting the form or when switching from template to custom entry.
  void clear() {
    nameController.clear();
    amountController.clear();
    cancelUrlController.clear();
    cancelPhoneController.clear();
    cancelNotesController.clear();
    notesController.clear();
    searchController.clear();
  }

  /// Disposes all text controllers.
  ///
  /// **MUST be called when the form is no longer needed** (typically in dispose()).
  /// Failure to dispose controllers will cause memory leaks.
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// void dispose() {
  ///   formState.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    cancelUrlController.dispose();
    cancelPhoneController.dispose();
    cancelNotesController.dispose();
    notesController.dispose();
    searchController.dispose();
  }
}

/// Immutable data class containing validated form field values.
///
/// Used to transfer clean, validated data from the form to the save logic.
/// Optional fields are represented as nullable types.
class SubscriptionFormData {
  /// The subscription name (required, trimmed)
  final String name;

  /// The subscription amount (required, must be positive)
  final double amount;

  /// Optional cancellation URL (null if not provided)
  final String? cancelUrl;

  /// Optional cancellation phone number (null if not provided)
  final String? cancelPhone;

  /// Optional cancellation instructions (null if not provided)
  final String? cancelNotes;

  /// Optional general notes (null if not provided)
  final String? notes;

  const SubscriptionFormData({
    required this.name,
    required this.amount,
    this.cancelUrl,
    this.cancelPhone,
    this.cancelNotes,
    this.notes,
  });
}
