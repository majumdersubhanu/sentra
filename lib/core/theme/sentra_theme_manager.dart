import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sentra_theme_manager.g.dart';

enum SentraThemeMode { light, dark }

class SentraThemeConfig {
  final SentraThemeMode mode;
  final Color? primaryColor;

  const SentraThemeConfig({
    this.mode = SentraThemeMode.light,
    this.primaryColor,
  });

  SentraThemeConfig copyWith({SentraThemeMode? mode, Color? primaryColor}) {
    return SentraThemeConfig(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

@riverpod
class ThemeConfig extends _$ThemeConfig {
  @override
  SentraThemeConfig build() {
    return const SentraThemeConfig();
  }

  void setThemeMode(SentraThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }
}
