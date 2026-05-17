import 'package:flutter/material.dart';
import '../tokens/sentra_colors.dart';
import '../tokens/sentra_typography.dart';

class SentraTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: SentraColors.primary500,
    scaffoldBackgroundColor: SentraColors.gray50,
    colorScheme: const ColorScheme.light(
      primary: SentraColors.primary500,
      onPrimary: Colors.white,
      secondary: SentraColors.primary700,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: SentraColors.gray900,
      error: SentraColors.error,
    ),
    textTheme: TextTheme(
      displayLarge: SentraTypography.h1,
      displayMedium: SentraTypography.h2,
      displaySmall: SentraTypography.h3,
      bodyLarge: SentraTypography.bodyLarge,
      bodyMedium: SentraTypography.bodyMedium,
      bodySmall: SentraTypography.bodySmall,
      labelLarge: SentraTypography.label,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: SentraColors.primary500,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: SentraColors.primary500,
      onPrimary: Colors.white,
      secondary: SentraColors.primary100,
      onSecondary: SentraColors.gray900,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: SentraColors.error,
    ),
    textTheme: TextTheme(
      displayLarge: SentraTypography.h1.copyWith(color: Colors.white),
      displayMedium: SentraTypography.h2.copyWith(color: Colors.white),
      displaySmall: SentraTypography.h3.copyWith(color: Colors.white),
      bodyLarge: SentraTypography.bodyLarge.copyWith(
        color: SentraColors.gray100,
      ),
      bodyMedium: SentraTypography.bodyMedium.copyWith(
        color: SentraColors.gray200,
      ),
      bodySmall: SentraTypography.bodySmall.copyWith(
        color: SentraColors.gray200,
      ),
      labelLarge: SentraTypography.label.copyWith(color: Colors.white),
    ),
  );
}
