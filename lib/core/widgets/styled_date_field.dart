import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// A styled date picker field that matches TextFormField styling.
///
/// Replaces ListTile-based date pickers with a consistent container
/// that matches the InputDecorationTheme from app/theme.dart.
///
/// ## Usage
///
/// ```dart
/// StyledDateField(
///   label: 'Next Billing Date',
///   value: _nextBillingDate,
///   firstDate: DateTime.now(),
///   lastDate: DateTime.now().add(const Duration(days: 730)),
///   onChanged: (date) => setState(() => _nextBillingDate = date),
/// )
/// ```
///
/// ## Design Philosophy
///
/// This widget solves the visual inconsistency where date pickers used
/// ListTile while other form fields used TextFormField. Now all form
/// fields have the same visual appearance and interaction patterns.
class StyledDateField extends StatefulWidget {
  /// The field label displayed above the date
  final String label;

  /// The current date value
  final DateTime value;

  /// The earliest selectable date (defaults to 1900)
  final DateTime? firstDate;

  /// The latest selectable date (defaults to 2100)
  final DateTime? lastDate;

  /// Callback when date is changed
  final ValueChanged<DateTime> onChanged;

  /// Optional hint text when no date is selected
  final String? hintText;

  const StyledDateField({
    super.key,
    required this.label,
    required this.value,
    this.firstDate,
    this.lastDate,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<StyledDateField> createState() => _StyledDateFieldState();
}

class _StyledDateFieldState extends State<StyledDateField> {
  bool _isFocused = false;

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.value,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      widget.onChanged(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (matching TextFormField label style)
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSizes.xs),

        // Date Field Container
        GestureDetector(
          onTap: _selectDate,
          onTapDown: (_) => setState(() => _isFocused = true),
          onTapUp: (_) => setState(() => _isFocused = false),
          onTapCancel: () => setState(() => _isFocused = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: _isFocused ? AppColors.primary : AppColors.border,
                width: _isFocused ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.base,
              vertical: AppSizes.base,
            ),
            child: Row(
              children: [
                // Date Value
                Expanded(
                  child: Text(
                    dateFormat.format(widget.value),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Calendar Icon
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
