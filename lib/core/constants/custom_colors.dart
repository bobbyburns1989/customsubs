import 'package:flutter/material.dart';

/// Theme-aware color palette for CustomSubs.
///
/// Provides typed access to all semantic colors via `Theme.of(context).extension<CustomColors>()`.
/// Use the `context.colors` shorthand from `theme_extensions.dart`.
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.background,
    required this.surface,
    required this.primarySurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.divider,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.success,
    required this.warning,
    required this.error,
    required this.trial,
    required this.inactive,
  });

  final Color background;
  final Color surface;
  final Color primarySurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color divider;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color success;
  final Color warning;
  final Color error;
  final Color trial;
  final Color inactive;

  /// Light mode — current AppColors values.
  static const light = CustomColors(
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    primarySurface: Color(0xFFEFF3F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFF1F5F9),
    primary: Color(0xFF5F8A6F),
    primaryLight: Color(0xFF7DA68A),
    primaryDark: Color(0xFF4A7359),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    trial: Color(0xFFF59E0B),
    inactive: Color(0xFF94A3B8),
  );

  /// Dark mode — inverted slate scale, brand green preserved.
  static const dark = CustomColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primarySurface: Color(0xFF1A2E1F),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    border: Color(0xFF334155),
    divider: Color(0xFF1E293B),
    primary: Color(0xFF5F8A6F),
    primaryLight: Color(0xFF7DA68A),
    primaryDark: Color(0xFF4A7359),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    trial: Color(0xFFF59E0B),
    inactive: Color(0xFF94A3B8),
  );

  @override
  CustomColors copyWith({
    Color? background,
    Color? surface,
    Color? primarySurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? divider,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? success,
    Color? warning,
    Color? error,
    Color? trial,
    Color? inactive,
  }) {
    return CustomColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primarySurface: primarySurface ?? this.primarySurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      trial: trial ?? this.trial,
      inactive: inactive ?? this.inactive,
    );
  }

  @override
  CustomColors lerp(CustomColors? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      trial: Color.lerp(trial, other.trial, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
    );
  }
}
