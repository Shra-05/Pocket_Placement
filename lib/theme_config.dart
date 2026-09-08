import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';

class AppThemeConfig {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color accent;
  final Color text;
  final IconData icon;

  const AppThemeConfig({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.accent,
    required this.text,
    required this.icon,
  });

  static AppThemeConfig fromTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.forest:
        return const AppThemeConfig(
          primary: Color(0xFF0D5148),
          secondary: Color(0xFF06251F),
          background: Color(0xFF07120F),
          surface: Color(0xFF0B211C),
          accent: Color(0xFF4DE4FF),
          text: Colors.white,
          icon: Icons.forest_rounded,
        );

      case AppTheme.cyberpunk:
        return const AppThemeConfig(
          primary: Color(0xFF4B176E),
          secondary: Color(0xFF101A51),
          background: Color(0xFF070313),
          surface: Color(0xFF120A25),
          accent: Color(0xFFB56CFF),
          text: Colors.white,
          icon: Icons.memory_rounded,
        );

      case AppTheme.kingdom:
        return const AppThemeConfig(
          primary: Color(0xFF71451C),
          secondary: Color(0xFF321B15),
          background: Color(0xFF100805),
          surface: Color(0xFF21120A),
          accent: Color(0xFFFFC857),
          text: Colors.white,
          icon: Icons.castle_rounded,
        );
    }
  }
}