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
        final isSelected = color.value == selectedColorValue;

        return GestureDetector(
          onTap: () => onColorSelected(color.value),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
