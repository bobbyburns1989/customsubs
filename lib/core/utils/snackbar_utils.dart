import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// Modern, aesthetic snackbar builder matching CustomSubs design system
///
/// **Design Principles:**
/// - Floating behavior with 16px rounded corners (matches StandardCard)
/// - Material icons for instant visual categorization
/// - Color-coded by semantic meaning (green/red/amber/grey)
/// - Optional UNDO action with white text button
/// - Duration varies by severity (errors: 4s, success: 2s, default: 3s)
///
/// **Features:**
/// - Consistent with app's flat design aesthetic
/// - No drop shadows (clean, minimalist)
/// - White text for maximum contrast
/// - 16px margins (matches design system spacing)
///
/// **Usage:**
/// ```dart
/// // Simple success message
/// SnackBarUtils.show(
///   context,
///   SnackBarUtils.success('Subscription saved!'),
/// );
///
/// // With UNDO action
/// SnackBarUtils.show(
///   context,
///   SnackBarUtils.success(
///     'Subscription deleted',
///     onUndo: () async {
///       // Restore logic
///     },
///   ),
/// );
/// ```
class SnackBarUtils {
  // Private constructor to prevent instantiation (static utility class)
  SnackBarUtils._();

  /// Internal builder for consistent snackbar styling
  ///
  /// All public methods (success/error/warning/info) use this builder
  /// to ensure visual consistency across the app.
  static SnackBar _buildSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onUndo,
    String undoLabel = 'UNDO',
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg), // 16px
      ),
      margin: const EdgeInsets.all(AppSizes.base), // 16px
      duration: duration,
      action: onUndo != null
          ? SnackBarAction(
              label: undoLabel,
              textColor: Colors.white,
              onPressed: onUndo,
            )
          : null,
    );
  }

  /// Success snackbar (green, checkmark icon)
  ///
  /// **Use for:**
  /// - Successful save operations
  /// - Subscription added/updated
  /// - Settings changed successfully
  /// - Data exported successfully
  /// - Test notifications sent
  ///
  /// **Duration:** 2 seconds (quick confirmation)
  ///
  /// **Example:**
  /// ```dart
  /// SnackBarUtils.show(
  ///   context,
  ///   SnackBarUtils.success('Currency changed to USD'),
  /// );
  /// ```
  static SnackBar success(String message, {VoidCallback? onUndo}) {
    return _buildSnackBar(
      message: message,
      backgroundColor: AppColors.success, // #16A34A (brand green)
      icon: Icons.check_circle,
      duration: const Duration(seconds: 2),
      onUndo: onUndo,
    );
  }

  /// Error snackbar (red, error icon, longer duration)
  ///
  /// **Use for:**
  /// - Save/update failures
  /// - Network errors
  /// - Validation errors
  /// - Import/export failures
  /// - Permission denials
  ///
  /// **Duration:** 4 seconds (users need time to read error messages)
  ///
  /// **Example:**
  /// ```dart
  /// SnackBarUtils.show(
  ///   context,
  ///   SnackBarUtils.error('Failed to save subscription'),
  /// );
  /// ```
  static SnackBar error(String message, {VoidCallback? onUndo}) {
    return _buildSnackBar(
      message: message,
      backgroundColor: AppColors.error, // #EF4444 (red)
      icon: Icons.error,
      duration: const Duration(seconds: 4),
      onUndo: onUndo,
    );
  }

  /// Warning snackbar (amber, warning icon)
  ///
  /// **Use for:**
  /// - Caution messages
  /// - Potentially destructive actions completed
  /// - Rate limiting warnings
  /// - Beta feature notices
  /// - Data loss warnings
  ///
  /// **Duration:** 3 seconds (standard)
  ///
  /// **Example:**
  /// ```dart
  /// SnackBarUtils.show(
  ///   context,
  ///   SnackBarUtils.warning('All data deleted'),
  /// );
  /// ```
  static SnackBar warning(String message, {VoidCallback? onUndo}) {
    return _buildSnackBar(
      message: message,
      backgroundColor: AppColors.warning, // #F59E0B (amber)
      icon: Icons.warning,
      duration: const Duration(seconds: 3),
      onUndo: onUndo,
    );
  }

  /// Info snackbar (grey, info icon)
  ///
  /// **Use for:**
  /// - Informational messages
  /// - Tips and hints
  /// - Neutral state changes
  /// - UNDO confirmation ("Subscription restored")
  /// - General notifications
  ///
  /// **Duration:** 3 seconds (standard)
  ///
  /// **Example:**
  /// ```dart
  /// SnackBarUtils.show(
  ///   context,
  ///   SnackBarUtils.info('Subscription restored'),
  /// );
  /// ```
  static SnackBar info(String message, {VoidCallback? onUndo}) {
    return _buildSnackBar(
      message: message,
      backgroundColor: AppColors.textSecondary, // #64748B (grey)
      icon: Icons.info,
      duration: const Duration(seconds: 3),
      onUndo: onUndo,
    );
  }

  /// Helper method to show snackbar (reduces boilerplate)
  ///
  /// Instead of:
  /// ```dart
  /// ScaffoldMessenger.of(context).showSnackBar(
  ///   SnackBarUtils.success('Message'),
  /// );
  /// ```
  ///
  /// Simply use:
  /// ```dart
  /// SnackBarUtils.show(
  ///   context,
  ///   SnackBarUtils.success('Message'),
  /// );
  /// ```
  static void show(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
