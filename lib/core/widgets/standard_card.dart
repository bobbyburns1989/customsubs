import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// Standard card widget for consistent styling across the app.
///
/// **Purpose:** Eliminate visual consistency drift by providing a single,
/// reusable card style with standardized radius, border, and padding.
///
/// **Design System:**
/// - Border radius: Always `radiusLg` (16px)
/// - Border width: Always 1.5px
/// - Default padding: `lg` (20px)
/// - Default margin: `zero` (full width in parent)
///
/// ## Usage
///
/// ```dart
/// StandardCard(
///   child: Column(
///     children: [
///       Text('Title'),
///       Text('Content'),
///     ],
///   ),
/// )
/// ```
///
/// **With custom padding:**
/// ```dart
/// StandardCard(
///   padding: EdgeInsets.all(AppSizes.xl),
///   child: Text('More spacious'),
/// )
/// ```
///
/// **Colored variant:**
/// ```dart
/// StandardCard(
///   backgroundColor: AppColors.primarySurface,
///   child: Text('Tinted background'),
/// )
/// ```
class StandardCard extends StatelessWidget {
  /// The content of the card
  final Widget child;

  /// Internal padding of the card content
  /// Defaults to `EdgeInsets.all(AppSizes.lg)` (20px all sides)
  final EdgeInsets? padding;

  /// External margin of the card
  /// Defaults to `EdgeInsets.zero` (full width in parent)
  final EdgeInsets? margin;

  /// Background color of the card
  /// Defaults to `AppColors.surface` (white)
  final Color? backgroundColor;

  const StandardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSizes.lg),
        child: child,
      ),
    );
  }
}
