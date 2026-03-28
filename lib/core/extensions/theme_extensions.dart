import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/custom_colors.dart';

/// Shorthand for accessing [CustomColors] from any [BuildContext].
///
/// Usage: `context.colors.textSecondary`
extension CustomColorsExtension on BuildContext {
  CustomColors get colors => Theme.of(this).extension<CustomColors>()!;
}
