library;

/// Subtle press animation widget for micro-interactions.
///
/// Wraps any widget with a barely perceptible press animation (1-2% scale down).
/// This creates tactile feedback without being distracting or obvious.
///
/// ## Usage
///
/// ```dart
/// SubtlePressable(
///   onPressed: () => print('tapped'),
///   child: ElevatedButton(
///     onPressed: null, // Set to null - gesture handles tap
///     child: const Text('Press Me'),
///   ),
/// )
/// ```
///
/// ## Design Philosophy
///
/// This animation is intentionally **very subtle** (default 2% scale down).
/// Users won't consciously notice it, but it makes buttons feel more responsive
/// and the app feel more polished.
///
/// ## Parameters
///
/// - `child`: The widget to make pressable
/// - `onPressed`: Callback when pressed (if null, no animation)
/// - `scale`: Scale factor when pressed (default 0.98 = 2% shrink)
///
/// ## Examples
///
/// ```dart
/// // Standard button with subtle press
/// SubtlePressable(
///   onPressed: () => context.push('/settings'),
///   child: ElevatedButton(
///     onPressed: null,
///     child: const Text('Settings'),
///   ),
/// )
///
/// // Extra subtle (1% shrink) for cards
/// SubtlePressable(
///   onPressed: () => showDetails(),
///   scale: 0.99,
///   child: Card(
///     child: ListTile(title: Text('Item')),
///   ),
/// )
/// ```

import 'package:flutter/material.dart';

class SubtlePressable extends StatefulWidget {
  /// The widget to wrap with press animation
  final Widget child;

  /// Callback when the widget is tapped
  final VoidCallback? onPressed;

  /// Scale factor when pressed (default 0.98 = 2% shrink)
  ///
  /// - 0.98 (2% shrink) - Default, good for buttons
  /// - 0.99 (1% shrink) - Extra subtle, good for cards
  /// - 0.97 (3% shrink) - More noticeable, use sparingly
  final double scale;

  const SubtlePressable({
    super.key,
    required this.child,
    required this.onPressed,
    this.scale = 0.98,
  });

  @override
  State<SubtlePressable> createState() => _SubtlePressableState();
}

class _SubtlePressableState extends State<SubtlePressable> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // If no onPressed callback, just return child without animation
    if (widget.onPressed == null) {
      return widget.child;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
