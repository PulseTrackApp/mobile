import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surface,
    surface: AppColors.surface,
    card: AppColors.card,
    text: AppColors.dark,
    muted: AppColors.muted,
    border: AppColors.border,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark,
    surface: AppColors.darkSurface,
    card: AppColors.darkCard,
    text: Colors.white,
    muted: const Color(0xFFA7B0BA),
    border: AppColors.darkBorder,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color surface,
    required Color card,
    required Color text,
    required Color muted,
    required Color border,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: surface,
      surfaceContainerLowest: card,
      outlineVariant: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: 'Roboto',
      textTheme: _textTheme(text: text, muted: muted),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: text,
          backgroundColor: card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: card,
          foregroundColor: muted,
          selectedBackgroundColor: brightness == Brightness.dark
              ? Colors.white
              : AppColors.dark,
          selectedForegroundColor: brightness == Brightness.dark
              ? AppColors.dark
              : Colors.white,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        height: 62,
        indicatorColor: AppColors.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : muted,
            fontSize: 10,
            height: 1,
            letterSpacing: 0,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme({required Color text, required Color muted}) {
    return TextTheme(
      displaySmall: TextStyle(
        color: text,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
      headlineSmall: TextStyle(
        color: text,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: text,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: text,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: muted,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    );
  }
}
