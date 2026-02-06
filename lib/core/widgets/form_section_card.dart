import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

/// A reusable card wrapper for form sections with optional collapse functionality.
///
/// Provides consistent styling across all form sections with:
/// - 1.5px border with radiusLg (16px) corners
/// - AppSizes.lg (20px) internal padding
/// - Optional section header with icon, title, and subtitle
/// - White surface background
/// - Optional collapse/expand with smooth animation
/// - Optional collapsed preview widget
///
/// ## Usage
///
/// **Always Expanded (Required Fields):**
/// ```dart
/// FormSectionCard(
///   title: 'Subscription Details',
///   icon: Icons.edit_outlined,
///   isCollapsible: false, // Always visible
///   child: Column(/* form fields */),
/// )
/// ```
///
/// **Collapsible with Preview:**
/// ```dart
/// FormSectionCard(
///   title: 'Appearance',
///   subtitle: 'Choose a color',
///   icon: Icons.palette_outlined,
///   isCollapsible: true,
///   initiallyExpanded: false,
///   collapsedPreview: Container(/* preview widget */),
///   child: ColorPicker(/* ... */),
/// )
/// ```
///
/// ## Design Philosophy
///
/// This widget establishes visual hierarchy and grouping in forms.
/// Collapsible sections reduce form height while maintaining discoverability.
/// Critical sections (required fields, reminders) should use isCollapsible: false.
class FormSectionCard extends StatefulWidget {
  /// The section title displayed in the header
  final String title;

  /// Optional subtitle providing additional context
  final String? subtitle;

  /// Optional icon displayed in circular container
  final IconData? icon;

  /// The form content to display within the card
  final Widget child;

  /// Optional custom padding (defaults to AppSizes.lg)
  final EdgeInsets? padding;

  /// Whether this card can be collapsed (defaults to true)
  final bool isCollapsible;

  /// Whether the card starts expanded (defaults to false)
  final bool initiallyExpanded;

  /// Optional widget shown when collapsed (e.g., color preview dot)
  final Widget? collapsedPreview;

  const FormSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.padding,
    this.isCollapsible = true,
    this.initiallyExpanded = false,
    this.collapsedPreview,
  });

  @override
  State<FormSectionCard> createState() => _FormSectionCardState();
}

class _FormSectionCardState extends State<FormSectionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded || !widget.isCollapsible;
  }

  void _toggleExpanded() {
    if (widget.isCollapsible) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tappable Header
            GestureDetector(
              onTap: _toggleExpanded,
              behavior: HitTestBehavior.opaque,
              child: _buildHeader(theme),
            ),

            // Animated Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSizes.sm),
                        widget.child,
                      ],
                    )
                  : (widget.collapsedPreview != null
                      ? widget.collapsedPreview!
                      : const SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    // If no icon, just show title and subtitle with optional chevron
    if (widget.icon == null) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null && _isExpanded) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.isCollapsible) _buildChevron(),
        ],
      );
    }

    // With icon: horizontal layout with chevron
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Container (circular, primary surface background)
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.base),

        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.subtitle != null && _isExpanded) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Chevron Icon (if collapsible)
        if (widget.isCollapsible) _buildChevron(),
      ],
    );
  }

  Widget _buildChevron() {
    return AnimatedRotation(
      turns: _isExpanded ? 0.5 : 0, // 180° rotation when expanded
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: const Icon(
        Icons.expand_more,
        color: AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
