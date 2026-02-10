import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// A small, rounded badge displaying subscription status with smooth color transitions.
///
/// This widget animates color changes when the status updates, providing a polished
/// visual experience for state transitions (e.g., Trial → Paid, Active → Paused).
///
/// ## Animated Properties
///
/// - Background color (15% opacity of provided color)
/// - Text color (full opacity of provided color)
/// - Transitions: 200ms with Curves.easeOut
///
/// ## Usage
///
/// ```dart
/// // Trial badge (amber)
/// StatusBadge(
///   label: 'Trial',
///   color: AppColors.trial,
/// )
///
/// // Paid badge (green)
/// StatusBadge(
///   label: 'Paid',
///   color: AppColors.success,
/// )
///
/// // Paused badge (gray)
/// StatusBadge(
///   label: 'Paused',
///   color: AppColors.inactive,
/// )
/// ```
///
/// ## Animation Behavior
///
/// When the color changes (e.g., user marks subscription as paid), both the
/// background and text color smoothly transition to the new color over 200ms.
/// This creates a polished, premium feel for status changes.
///
/// See: docs/design/MICRO_ANIMATIONS.md (#5 Status Badge Color Transitions)
class StatusBadge extends StatelessWidget {
  /// The text label displayed in the badge
  final String label;

  /// The color used for both background (15% opacity) and text (full opacity)
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.base,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        child: Text(label),
      ),
    );
  }
}
