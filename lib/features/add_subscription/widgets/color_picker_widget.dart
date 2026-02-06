import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';

class ColorPickerWidget extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: AppColors.subscriptionColors.map((color) {
        final isSelected = color.toARGB32() == selectedColorValue;

        return _ColorPickerItem(
          color: color,
          isSelected: isSelected,
          onTap: () => onColorSelected(color.toARGB32()),
        );
      }).toList(),
    );
  }
}

/// Individual color picker item with selection animation
class _ColorPickerItem extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorPickerItem({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ColorPickerItem> createState() => _ColorPickerItemState();
}

class _ColorPickerItemState extends State<_ColorPickerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Pulse animation: 1.0 -> 0.98 -> 1.02 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.98),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.02),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0),
        weight: 34,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward(from: 0.0); // Play pulse animation
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected ? AppColors.textPrimary : Colors.transparent,
                  width: 3,
                ),
              ),
              child: widget.isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
