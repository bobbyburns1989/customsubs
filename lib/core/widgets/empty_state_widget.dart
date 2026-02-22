/// Reusable empty state widget with icon, title, subtitle, and optional CTA.
///
/// Provides a consistent, engaging empty state experience across the app
/// with Material Icons, clear messaging, and actionable CTAs.
library;

import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// A reusable empty state widget with icon and optional call-to-action.
///
/// **Design System:**
/// - Centered layout with generous padding (AppSizes.xxl)
/// - Large Material Icon in circular container at top
/// - Title using headlineSmall with bold weight
/// - Subtitle using bodyLarge with textSecondary color
/// - Optional CTA button (FilledButton with icon)
/// - Subtle 300ms fade-in animation on mount
///
/// **Usage:**
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.inbox_outlined,
///   title: 'No subscriptions yet',
///   subtitle: 'Tap + to add your first one. We\'ll remind you before every charge.',
///   buttonText: 'Add Subscription',
///   onButtonPressed: () => context.push('/add'),
/// )
/// ```
///
/// **Without Button:**
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.search_off_outlined,
///   title: 'No templates found',
///   subtitle: 'Try a different search term or create a custom subscription below',
///   iconSize: 64, // Smaller for inline display
/// )
/// ```
class EmptyStateWidget extends StatefulWidget {
  /// Material Icon to display.
  ///
  /// Example: `Icons.inbox_outlined`, `Icons.search_off_outlined`
  final IconData icon;

  /// Main title text displayed prominently.
  ///
  /// Uses theme's headlineSmall with bold weight.
  /// Example: `'No subscriptions yet'`
  final String title;

  /// Supporting subtitle text with additional context or guidance.
  ///
  /// Uses theme's bodyLarge with textSecondary color.
  /// Example: `'Tap + to add your first one. We\'ll remind you before every charge.'`
  final String subtitle;

  /// Optional call-to-action button text.
  ///
  /// If provided along with [onButtonPressed], displays a FilledButton with
  /// an add icon. Leave null to hide the button.
  final String? buttonText;

  /// Optional callback when CTA button is pressed.
  ///
  /// Must be provided if [buttonText] is set. Typically navigates to an
  /// action screen or triggers a creation flow.
  final VoidCallback? onButtonPressed;

  /// Size of the icon in logical pixels.
  ///
  /// Defaults to 80.0 for primary empty states. Use smaller values
  /// (e.g., 64.0) for inline/secondary empty states like search results.
  final double iconSize;

  /// Background color for the circular icon container.
  ///
  /// Defaults to AppColors.primarySurface (light green).
  final Color? iconBackgroundColor;

  /// Color for the icon itself.
  ///
  /// Defaults to AppColors.primary (green).
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize = 80.0,
    this.iconBackgroundColor,
    this.iconColor,
  }) : assert(
          (buttonText == null && onButtonPressed == null) ||
              (buttonText != null && onButtonPressed != null),
          'buttonText and onButtonPressed must both be null or both be non-null',
        );

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller for subtle fade-in effect
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Fade animation from 0.0 (transparent) to 1.0 (opaque)
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start animation immediately on mount
    _controller.forward();
  }

  @override
  void dispose() {
    // Clean up animation controller to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine icon container size (1.8x the icon size for nice padding)
    final containerSize = widget.iconSize * 1.8;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: SingleChildScrollView(
          // Allow scrolling if content is too tall for screen
          padding: const EdgeInsets.all(AppSizes.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon in Circular Container
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor ?? AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Title
              Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),

              // Subtitle
              Text(
                widget.subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              // Call-to-Action Button (optional)
              if (widget.buttonText != null &&
                  widget.onButtonPressed != null) ...[
                const SizedBox(height: AppSizes.xxl),
                FilledButton.icon(
                  onPressed: widget.onButtonPressed,
                  icon: const Icon(Icons.add),
                  label: Text(widget.buttonText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
