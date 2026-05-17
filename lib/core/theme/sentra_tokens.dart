import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

// ─── Braid Color Tokens ────────────────────────────────────────────────────

final $brand = ColorToken('brand');
final $formAccent = ColorToken('formAccent');
final $critical = ColorToken('critical');
final $positive = ColorToken('positive');
final $caution = ColorToken('caution');
final $promote = ColorToken('promote');

final $surface = ColorToken('surface');
final $body = ColorToken('body');
final $border = ColorToken('border');
final $borderMuted = ColorToken('border.muted');

final $textPrimary = ColorToken('text.primary');
final $textSecondary = ColorToken('text.secondary');
final $textMuted = ColorToken('text.muted');
final $textInverse = ColorToken('text.inverse');

// ─── Resolved Color Constants (Braid Light Mode) ──────────────────────────

class BraidColors {
  BraidColors._();

  static const brand = Color(0xFF1E40AF); // Blue 800
  static const formAccent = Color(0xFF2563EB); // Blue 600
  static const critical = Color(0xFFDC2626); // Red 600
  static const positive = Color(0xFF16A34A); // Green 600
  static const caution = Color(0xFFD97706); // Amber 600
  static const promote = Color(0xFF7C3AED); // Purple 600

  static const surface = Color(0xFFFFFFFF);
  static const body = Color(0xFFF3F4F6); // Gray 100
  static const border = Color(0xFFD1D5DB); // Gray 300
  static const borderMuted = Color(0xFFE5E7EB); // Gray 200

  static const textPrimary = Color(0xFF111827); // Gray 900
  static const textSecondary = Color(0xFF4B5563); // Gray 600
  static const textMuted = Color(0xFF9CA3AF); // Gray 400
  static const textInverse = Color(0xFFFFFFFF); // White
}

// ─── Convenience aliases ────────────────────────────────────────────────────

const kBrand = BraidColors.brand;
const kFormAccent = BraidColors.formAccent;
const kCritical = BraidColors.critical;
const kPositive = BraidColors.positive;
const kCaution = BraidColors.caution;
const kPromote = BraidColors.promote;

const kSurface = BraidColors.surface;
const kBody = BraidColors.body;
const kBorder = BraidColors.border;
const kBorderMuted = BraidColors.borderMuted;

const kTextPrimary = BraidColors.textPrimary;
const kTextSecondary = BraidColors.textSecondary;
const kTextMuted = BraidColors.textMuted;
const kTextInverse = BraidColors.textInverse;

// Aliases mapping old Sentra colors to Braid semantic colors
// This helps minimize refactoring in screens while preserving semantics
const kAccent = kBrand;
const kSuccess = kPositive;
const kWarning = kCaution;
const kDanger = kCritical;
const kInfo = kFormAccent;
const kSurfaceElevated = kSurface;
const kSurfaceMuted = kBody;
const kEmerald500 = kPositive;
const kAmber500 = kCaution;
const kRed500 = kCritical;
const kPurple500 = kPromote;

// ─── Space Tokens (4px Grid) ────────────────────────────────────────────────

final $space1 = SpaceToken('space.1');
final $space2 = SpaceToken('space.2');
final $space3 = SpaceToken('space.3');
final $space4 = SpaceToken('space.4');
final $space5 = SpaceToken('space.5');
final $space6 = SpaceToken('space.6');
final $space8 = SpaceToken('space.8');
final $space10 = SpaceToken('space.10');
final $space12 = SpaceToken('space.12');

// ─── Radius Tokens ──────────────────────────────────────────────────────────

final $radiusSm = RadiusToken('radius.sm');
final $radiusMd = RadiusToken('radius.md');
final $radiusLg = RadiusToken('radius.lg');
final $radiusXl = RadiusToken('radius.xl');
final $radiusFull = RadiusToken('radius.full');

// ─── Light Theme Token Map ──────────────────────────────────────────────────

final braidLightColors = <ColorToken, Color>{
  $brand: BraidColors.brand,
  $formAccent: BraidColors.formAccent,
  $critical: BraidColors.critical,
  $positive: BraidColors.positive,
  $caution: BraidColors.caution,
  $promote: BraidColors.promote,
  $surface: BraidColors.surface,
  $body: BraidColors.body,
  $border: BraidColors.border,
  $borderMuted: BraidColors.borderMuted,
  $textPrimary: BraidColors.textPrimary,
  $textSecondary: BraidColors.textSecondary,
  $textMuted: BraidColors.textMuted,
  $textInverse: BraidColors.textInverse,
};

final braidSpaces = <SpaceToken, double>{
  $space1: 4,
  $space2: 8,
  $space3: 12,
  $space4: 16,
  $space5: 20,
  $space6: 24,
  $space8: 32,
  $space10: 40,
  $space12: 48,
};

final braidRadii = <RadiusToken, Radius>{
  $radiusSm: const Radius.circular(4),
  $radiusMd: const Radius.circular(8),
  $radiusLg: const Radius.circular(12),
  $radiusXl: const Radius.circular(16),
  $radiusFull: const Radius.circular(999),
};
