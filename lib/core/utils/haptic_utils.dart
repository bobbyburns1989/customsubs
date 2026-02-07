import 'package:flutter/services.dart';

/// Centralized haptic feedback utilities for CustomSubs
///
/// Provides consistent tactile feedback across the app to enhance user experience
/// and provide confirmation of user actions. All methods are async to avoid blocking
/// the UI thread, but complete quickly (~10-50ms depending on intensity).
///
/// **Usage Guidelines:**
/// - `light()` - Navigation actions, icon buttons, text buttons, list tile taps
/// - `medium()` - Primary buttons, toggles, form submissions, state changes
/// - `heavy()` - Delete/destructive actions, pull-to-refresh, swipe dismissals
/// - `selection()` - Checkboxes, radio buttons, dropdown selections
///
/// **Example:**
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     await HapticUtils.medium(); // Confirm button press
///     // ... perform action
///   },
///   child: const Text('Save'),
/// )
/// ```
///
/// **Note:** Haptics fail gracefully on unsupported devices (no-op).
/// Physical devices required for testing - simulators/emulators don't support haptics.
class HapticUtils {
  // Private constructor to prevent instantiation (static utility class)
  HapticUtils._();

  /// Light haptic feedback (10-20ms)
  ///
  /// **Use for:**
  /// - Navigation actions (back button, navigation drawer)
  /// - Icon buttons (settings, info, search)
  /// - Text buttons (cancel, dismiss)
  /// - List tile taps (opening detail screens)
  /// - Minor UI interactions
  ///
  /// **Intensity:** Subtle, gentle tap sensation
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback (30-40ms)
  ///
  /// **Use for:**
  /// - Primary action buttons (save, add, confirm)
  /// - Filled/elevated buttons
  /// - Toggle switches and state changes
  /// - Form submissions
  /// - "Mark as Paid" toggles
  /// - Color/template selections
  ///
  /// **Intensity:** Noticeable, distinct feedback
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback (50ms)
  ///
  /// **Use for:**
  /// - Delete/destructive actions
  /// - Pull-to-refresh completion
  /// - Swipe-to-dismiss actions
  /// - Critical confirmations
  /// - Error states that require attention
  ///
  /// **Intensity:** Strong, attention-grabbing feedback
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback (quick click)
  ///
  /// **Use for:**
  /// - Checkbox toggles
  /// - Radio button selections
  /// - Segmented control changes
  /// - Picker/dropdown selections
  /// - Multi-select interactions
  ///
  /// **Intensity:** Crisp, click-like sensation
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
