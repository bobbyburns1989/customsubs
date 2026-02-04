import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF16A34A); // Green 600
  static const Color primaryLight = Color(0xFF22C55E); // Green 500
  static const Color primaryDark = Color(0xFF15803D); // Green 700
  static const Color primarySurface = Color(0xFFF0FDF4); // Green 50

  // Neutrals
  static const Color background = Color(0xFFFAFAFA); // Near-white
  static const Color surface = Color(0xFFFFFFFF); // White cards
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // Semantic
  static const Color success = Color(0xFF16A34A); // Same as primary
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color trial = Color(0xFFF59E0B); // Amber for trial badges
  static const Color inactive = Color(0xFF94A3B8); // Slate 400 for paused

  // Category Colors (for subscription color picker)
  static const List<Color> subscriptionColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF84CC16), // Lime
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF78716C), // Stone
  ];
}
