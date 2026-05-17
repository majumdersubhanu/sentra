import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra/core/theme/sentra_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Theme Configuration & Management
// ═══════════════════════════════════════════════════════════════════════════

enum SentraThemeMode {
  light,
  dark,
}

/// Theme configuration with customizable colors.
class SentraThemeConfig {
  final SentraThemeMode mode;
  final Color? primaryColor; // Override brand color
  final Color? accentColor; // Override form accent
  final Color? surfaceColor; // Override surface
  final Color? errorColor; // Override critical

  const SentraThemeConfig({
    this.mode = SentraThemeMode.light,
    this.primaryColor,
    this.accentColor,
    this.surfaceColor,
    this.errorColor,
  });

  /// Create a copy with modified fields.
  SentraThemeConfig copyWith({
    SentraThemeMode? mode,
    Color? primaryColor,
    Color? accentColor,
    Color? surfaceColor,
    Color? errorColor,
  }) {
    return SentraThemeConfig(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentraThemeConfig &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          surfaceColor == other.surfaceColor &&
          errorColor == other.errorColor;

  @override
  int get hashCode =>
      mode.hashCode ^
      primaryColor.hashCode ^
      accentColor.hashCode ^
      surfaceColor.hashCode ^
      errorColor.hashCode;
}

/// Riverpod provider for theme configuration.
final themeConfigProvider =
    StateNotifierProvider<ThemeConfigNotifier, SentraThemeConfig>((ref) {
  return ThemeConfigNotifier();
});

class ThemeConfigNotifier extends StateNotifier<SentraThemeConfig> {
  ThemeConfigNotifier() : super(const SentraThemeConfig());

  void setThemeMode(SentraThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }

  void setAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
  }

  void setSurfaceColor(Color color) {
    state = state.copyWith(surfaceColor: color);
  }

  void setErrorColor(Color color) {
    state = state.copyWith(errorColor: color);
  }

  /// Reset to default colors.
  void resetColors() {
    state = state.copyWith(
      primaryColor: null,
      accentColor: null,
      surfaceColor: null,
      errorColor: null,
    );
  }
}

/// Helper to build MaterialApp theme from configuration.
class SentraThemeBuilder {
  static ThemeData buildTheme(SentraThemeConfig config) {
    final isDark = config.mode == SentraThemeMode.dark;

    // Use custom colors or defaults
    final primaryColor =
        config.primaryColor ?? (isDark ? const Color(0xFF60A5FA) : kBrand);
    final errorColor =
        config.errorColor ?? (isDark ? const Color(0xFFEF5350) : kCritical);
    final surfaceColor =
        config.surfaceColor ?? (isDark ? const Color(0xFF1E1E1E) : kSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: config.accentColor ?? (isDark ? const Color(0xFF90CAF9) : kFormAccent),
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        outline: isDark ? const Color(0xFF424242) : kBorder,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : kBody,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF424242) : kBorderMuted,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(
            color: isDark ? const Color(0xFF424242) : kBorder,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFBDBDBD) : kTextSecondary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFBDBDBD) : kTextMuted,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? const Color(0xFFBDBDBD) : kTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDark ? const Color(0xFF9E9E9E) : kTextMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE0E0E0) : kTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFBDBDBD) : kTextSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFF9E9E9E) : kTextMuted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : kBody,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF424242) : kBorderMuted,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF424242) : kBorderMuted,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Widget to apply theme to the app.
class SentraThemeProvider extends ConsumerWidget {
  final Widget child;

  const SentraThemeProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeConfigProvider);
    final theme = SentraThemeBuilder.buildTheme(config);

    return Theme(
      data: theme,
      child: child,
    );
  }
}
