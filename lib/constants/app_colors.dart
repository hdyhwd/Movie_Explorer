import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Orange/Yellow theme from reference
  static const Color primary = Color(0xFFFFA500); // Bright Orange
  static const Color primaryDark = Color(0xFFFF8C00); // Dark Orange
  static const Color primaryLight = Color(0xFFFFB733); // Light Orange

  // Secondary Colors
  static const Color secondary = Color(0xFFFFD700); // Gold/Yellow
  static const Color accent = Color(0xFFFF6B35); // Red-Orange accent

  // Background Colors
  static const Color background = Color(0xFF000000); // Black background
  static const Color backgroundLight = Color(0xFF1A1A1A); // Dark gray
  static const Color cardBackground = Color(0xFF2A2A2A); // Card background
  static const Color surfaceColor = Color(0xFF1F1F1F); // Surface color

  // Text Colors
  static const Color textLight = Color(0xFFFFFFFF); // White
  static const Color textDark = Color(0xFF000000); // Black
  static const Color textGray = Color(0xFFB0B0B0); // Gray text
  static const Color textMuted = Color(0xFF808080); // Muted text

  // Additional Colors
  static const Color success = Color(0xFF21D07A); // Green for success
  static const Color error = Color(0xFFE74C3C); // Red for error
  static const Color warning = Color(0xFFF39C12); // Yellow for warning
  static const Color info = Color(0xFF3498DB); // Blue for info

  // Rating & Badge Colors
  static const Color ratingGold = Color(0xFFFFD700);
  static const Color bookmarkYellow = Color(0xFFFFC107);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Overlay Colors
  static const Color overlayDark = Color(0x99000000); // Semi-transparent black
  static const Color overlayLight = Color(0x33FFFFFF); // Semi-transparent white
}
