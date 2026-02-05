# Forms and Validation Guide

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Developers

**Comprehensive guide to form implementation and validation patterns in CustomSubs.**

This guide covers form state management, validation strategies, user input handling, and best practices.

---

## Table of Contents

1. [Form Pattern Overview](#form-pattern-overview)
2. [Form State Management](#form-state-management)
3. [Validation Strategies](#validation-strategies)
4. [Input Formatters](#input-formatters)
5. [Common Form Patterns](#common-form-patterns)
6. [Error Handling](#error-handling)
7. [Best Practices](#best-practices)

---

## Form Pattern Overview

### When to Use Forms

**Use forms for:**
- Creating/editing data (Add Subscription, Edit Subscription)
- Multi-field input (Settings configuration)
- Complex validation requirements

**Don't use forms for:**
- Single-field input (use direct input with setState)
- Simple toggles (use SwitchListTile directly)
- Read-only displays (use regular widgets)

### Form Architecture in CustomSubs

**Pattern:** `ConsumerStatefulWidget` + Local State + Repository

```
User Input
    ↓
TextEditingController / Local State Variables
    ↓
Form Validation (on submit)
    ↓
Build Domain Model
    ↓
Repository.upsert()
    ↓
Side Effects (notifications, navigation)
```

**Key principle:** Forms use **local transient state**, not Riverpod controllers.

---

## Form State Management

### Why Local State?

**Form state is transient:**
- Only exists while editing
- Doesn't need to persist
- Doesn't need reactive updates
- Doesn't need to be shared

**Use StatefulWidget for:**
- TextEditingControllers
- Dropdown selections
- Date/time picker values
- Checkbox/switch states
- Form validation state

### Pattern: ConsumerStatefulWidget

```dart
class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;  // null for create, ID for edit

  const AddSubscriptionScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState
    extends ConsumerState<AddSubscriptionScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers (MUST dispose!)
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  // Local state variables
  SubscriptionCycle _selectedCycle = SubscriptionCycle.monthly;
  DateTime _nextBillingDate = DateTime.now().add(Duration(days: 30));

  // Loading state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.subscriptionId != null) {
      _loadExistingData();
    }
  }

  @override
  void dispose() {
    // CRITICAL: Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Subscription')),
      body: Form(
        key: _formKey,
        child: /* form fields */,
      ),
    );
  }
}
```

### Controller Lifecycle

**CRITICAL:** Always dispose TextEditingControllers!

```dart
// ✅ CORRECT
@override
void dispose() {
  _nameController.dispose();
  _amountController.dispose();
  _notesController.dispose();
  super.dispose();  // Call super.dispose() LAST
}

// ❌ WRONG - Memory leak!
@override
void dispose() {
  super.dispose();
  // Controllers never disposed
}
```

---

## Validation Strategies

### Form-Level Validation

**Use `GlobalKey<FormState>` for multi-field validation:**

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(/* ... */),
      TextFormField(/* ... */),
    ],
  ),
)
```

**Trigger validation on submit:**

```dart
Future<void> _save() async {
  // Validate all fields
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fix the errors above')),
    );
    return;
  }

  // All fields valid - proceed with save
  await _saveToRepository();
}
```

### Field-Level Validation

**Use `validator` callback on TextFormField:**

```dart
TextFormField(
  controller: _nameController,
  decoration: InputDecoration(labelText: 'Name'),
  validator: (value) {
    // Return error string or null if valid
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }
    if (value.length > 50) {
      return 'Name must be 50 characters or less';
    }
    return null;  // Valid
  },
)
```

### Common Validation Rules

**Required field:**
```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }
  return null;
}
```

**Positive number:**
```dart
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
  if (amount > 999999) {
    return 'Amount is too large';
  }
  return null;
}
```

**Email format:**
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
```

**Length constraints:**
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Required';
  }
  if (value.length < 3) {
    return 'Must be at least 3 characters';
  }
  if (value.length > 100) {
    return 'Must be 100 characters or less';
  }
  return null;
}
```

**URL format:**
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return null;  // Optional field
  }
  final urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b',
  );
  if (!urlRegex.hasMatch(value)) {
    return 'Please enter a valid URL';
  }
  return null;
}
```

---

## Input Formatters

### Restrict Input Types

**Numeric input (with decimals):**
```dart
TextFormField(
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ],
)
```

**Integer only:**
```dart
TextFormField(
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
)
```

**Currency format:**
```dart
import 'package:flutter/services.dart';

TextFormField(
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    // Max 6 digits before decimal
    LengthLimitingTextInputFormatter(9),  // 123456.78
  ],
  decoration: InputDecoration(
    prefixText: '\$',  // or dynamically from currency
  ),
)
```

**Phone number:**
```dart
TextFormField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
    LengthLimitingTextInputFormatter(20),
  ],
)
```

**Alphanumeric only:**
```dart
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
  ],
)
```

---

## Common Form Patterns

### Pattern 1: Text Input Field

```dart
TextFormField(
  controller: _nameController,
  decoration: InputDecoration(
    labelText: 'Name',
    hintText: 'e.g., Netflix',
    prefixIcon: Icon(Icons.label_outline),
    helperText: 'Enter the subscription name',
  ),
  textCapitalization: TextCapitalization.words,
  validator: (value) =>
      value?.trim().isEmpty ?? true ? 'Required' : null,
  onChanged: (value) {
    // Optional: React to changes
  },
)
```

### Pattern 2: Dropdown Selection

```dart
DropdownButtonFormField<SubscriptionCycle>(
  value: _selectedCycle,
  decoration: InputDecoration(
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
      setState(() => _selectedCycle = value);
    }
  },
  validator: (value) => value == null ? 'Please select a cycle' : null,
)
```

### Pattern 3: Date Picker

```dart
ListTile(
  leading: Icon(Icons.event),
  title: Text('Next Billing Date'),
  subtitle: Text(_nextBillingDate.toLocal().toString().split(' ')[0]),
  trailing: Icon(Icons.chevron_right),
  onTap: () async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
      helpText: 'Select billing date',
    );
    if (pickedDate != null) {
      setState(() => _nextBillingDate = pickedDate);
    }
  },
)
```

### Pattern 4: Toggle Switch

```dart
SwitchListTile(
  title: Text('Free Trial'),
  subtitle: Text('This subscription is in a free trial'),
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
)
```

### Pattern 5: Conditional Fields

```dart
Column(
  children: [
    SwitchListTile(
      title: Text('Free Trial'),
      value: _isTrial,
      onChanged: (value) => setState(() => _isTrial = value),
    ),

    // Only show trial fields if enabled
    if (_isTrial) ...[
      SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(labelText: 'Trial End Date'),
        // ...
      ),
      SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(labelText: 'Post-Trial Amount'),
        // ...
      ),
    ],
  ],
)
```

---

## Error Handling

### Validation Errors

**Show inline errors (automatic with validator):**
```dart
TextFormField(
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  // Error automatically shows below field
)
```

**Show snackbar on validation failure:**
```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fix the errors above'),
        backgroundColor: AppColors.error,
      ),
    );
    return;
  }
  // ...
}
```

### Save Errors

**Handle repository/service errors:**
```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final subscription = _buildSubscription();
    final repository = await ref.read(subscriptionRepositoryProvider.future);
    await repository.upsert(subscription);

    // Success - navigate back
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription saved!')),
      );
    }
  } catch (e) {
    // Error - show message and stay on form
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
```

### Loading State

**Disable form during save:**
```dart
ElevatedButton(
  onPressed: _isSaving ? null : _save,  // Disable when saving
  child: _isSaving
      ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      : Text('Save'),
)
```

---

## Best Practices

### 1. Always Validate Before Save

```dart
// ✅ CORRECT
if (!_formKey.currentState!.validate()) {
  // Show error, don't save
  return;
}
await _saveToRepository();

// ❌ WRONG - Saves invalid data
await _saveToRepository();
```

### 2. Always Dispose Controllers

```dart
// ✅ CORRECT
@override
void dispose() {
  _nameController.dispose();
  _amountController.dispose();
  super.dispose();
}

// ❌ WRONG - Memory leak
@override
void dispose() {
  super.dispose();
}
```

### 3. Check mounted Before Navigation

```dart
// ✅ CORRECT
await repository.upsert(subscription);
if (mounted) {
  Navigator.pop(context);
}

// ❌ WRONG - Can crash if widget disposed
await repository.upsert(subscription);
Navigator.pop(context);  // Might throw if async operation took long
```

### 4. Use Appropriate Keyboard Types

```dart
// ✅ CORRECT
TextFormField(
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  // Shows numeric keyboard with decimal point
)

// ❌ WRONG - Shows full keyboard for numbers
TextFormField(
  // No keyboardType specified
)
```

### 5. Provide Clear Error Messages

```dart
// ✅ CORRECT - Specific, actionable
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a subscription name';
  }
  if (value.length > 50) {
    return 'Name must be 50 characters or less';
  }
  return null;
}

// ❌ WRONG - Vague, unhelpful
validator: (value) {
  if (value?.isEmpty ?? true) {
    return 'Invalid';  // What's invalid? How to fix?
  }
  return null;
}
```

### 6. Use Input Formatters to Prevent Invalid Input

```dart
// ✅ CORRECT - Prevent invalid characters
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ],
  validator: (value) {
    // Validation is simpler because invalid chars are already blocked
    final amount = double.tryParse(value ?? '');
    return amount == null || amount <= 0 ? 'Invalid amount' : null;
  },
)

// ❌ WRONG - Allow any input, catch in validation
TextFormField(
  // No input formatters
  validator: (value) {
    // Must handle all invalid cases: letters, symbols, etc.
    if (value == null) return 'Required';
    if (value.contains(RegExp(r'[^0-9.]'))) return 'Numbers only';
    // ... many more checks
  },
)
```

### 7. Provide Loading Feedback

```dart
// ✅ CORRECT - User knows something is happening
ElevatedButton(
  onPressed: _isSaving ? null : _save,
  child: _isSaving ? CircularProgressIndicator() : Text('Save'),
)

// ❌ WRONG - No feedback, user may tap multiple times
ElevatedButton(
  onPressed: _save,  // Always enabled
  child: Text('Save'),
)
```

### 8. Handle Empty Optional Fields

```dart
// ✅ CORRECT - Store null for empty optional fields
final notes = _notesController.text.trim().isEmpty
    ? null
    : _notesController.text.trim();

// ❌ WRONG - Store empty string (wastes space)
final notes = _notesController.text;
```

---

## Complete Example: Add Subscription Form

See `docs/templates/form-screen.dart` for a fully annotated example implementing all patterns and best practices.

---

## Quick Reference

| Task | Pattern |
|------|---------|
| Form validation | `GlobalKey<FormState>` + `_formKey.currentState!.validate()` |
| Required field | `validator: (v) => v?.isEmpty ?? true ? 'Required' : null` |
| Numeric input | `keyboardType: TextInputType.numberWithOptions(decimal: true)` |
| Restrict input | `inputFormatters: [FilteringTextInputFormatter.allow(...)]` |
| Dropdown | `DropdownButtonFormField<T>` with `onChanged: setState(...)` |
| Date picker | `ListTile` + `showDatePicker` + `setState(...)` |
| Toggle | `SwitchListTile` with `onChanged: setState(...)` |
| Conditional fields | `if (condition) ...[widgets]` |
| Loading state | `bool _isSaving` + disable button + show spinner |
| Save flow | Validate → Build model → Repository → Navigate |
| Error handling | Try-catch + SnackBar + reset loading state |

---

## Summary

**Form implementation checklist:**

1. ✅ Use `ConsumerStatefulWidget` for forms
2. ✅ Create `GlobalKey<FormState>` for validation
3. ✅ Create TextEditingControllers for text inputs
4. ✅ Create local state variables for dropdowns/pickers
5. ✅ Dispose all controllers in `dispose()`
6. ✅ Validate on submit with `_formKey.currentState!.validate()`
7. ✅ Use appropriate `keyboardType` for each field
8. ✅ Use `inputFormatters` to restrict invalid input
9. ✅ Show loading state during save
10. ✅ Handle errors with try-catch and user feedback
11. ✅ Check `mounted` before navigation
12. ✅ Test all validation rules and edge cases

**See also:**
- `docs/templates/form-screen.dart` - Complete annotated example
- `docs/architecture/state-management.md` - When to use forms vs controllers
- `docs/guides/adding-a-feature.md` - Feature implementation flow
