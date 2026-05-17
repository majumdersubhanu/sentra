import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'sentra_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Braid Reusable Styles — Composable Mix styles built from design tokens.
// ═══════════════════════════════════════════════════════════════════════════

// ─── Card Style ─────────────────────────────────────────────────────────────

/// Standard Braid card — used for all list items, detail sections, etc.
BoxStyler $card() {
  return BoxStyler()
      .color($surface())
      .borderRadiusAll($radiusLg())
      .borderAll(color: $borderMuted(), width: 1);
}

/// Elevated card — for content that sits higher above the surface (modals, popovers).
BoxStyler $cardElevated() {
  return BoxStyler()
      .color($surface())
      .borderRadiusAll($radiusLg())
      .borderAll(color: $borderMuted(), width: 1);
}

// ─── Badge / Status Chip ────────────────────────────────────────────────────

/// Creates a badge style for the given semantic color.
BoxStyler $badge(Color color) {
  return BoxStyler()
      .color(color.withValues(alpha: 0.1))
      .borderRadiusAll($radiusSm())
      .paddingOnly(horizontal: $space2(), vertical: 4);
}

/// Badge text style.
TextStyler $badgeText(Color color) {
  return TextStyler().color(color).fontSize(10).fontWeight(FontWeight.w700);
}

// ─── Section Card (Detail screens) ──────────────────────────────────────────

/// Detail screen section container.
BoxStyler $sectionCard() {
  return BoxStyler()
      .color($surface())
      .borderRadiusAll($radiusLg())
      .borderAll(color: $borderMuted(), width: 1)
      .padding(.all($space5()));
}

// ─── Filter Chip ────────────────────────────────────────────────────────────

/// Filter chip — inactive state.
BoxStyler $filterChip() {
  return BoxStyler()
      .color($surface())
      .borderRadiusAll($radiusFull())
      .borderAll(color: $borderMuted(), width: 1)
      .paddingOnly(horizontal: 14, vertical: $space2());
}

/// Filter chip — active state with accent color.
BoxStyler $filterChipActive(Color color) {
  return BoxStyler()
      .color(color.withValues(alpha: 0.1))
      .borderRadiusAll($radiusFull())
      .borderAll(color: color.withValues(alpha: 0.5), width: 1)
      .paddingOnly(horizontal: 14, vertical: $space2());
}

// ─── Buttons ────────────────────────────────────────────────────────────────

/// Primary action button.
BoxStyler $primaryButton() {
  return BoxStyler()
      .color($brand())
      .borderRadiusAll($radiusMd())
      .alignment(.center)
      .paddingOnly(horizontal: $space6(), vertical: $space3());
}

/// Danger action button.
BoxStyler $dangerButton() {
  return BoxStyler()
      .color($critical())
      .borderRadiusAll($radiusMd())
      .alignment(.center)
      .paddingOnly(horizontal: $space6(), vertical: $space3());
}

/// Secondary action button.
BoxStyler $secondaryButton() {
  return BoxStyler()
      .color($body())
      .borderRadiusAll($radiusMd())
      .alignment(.center)
      .paddingOnly(horizontal: $space6(), vertical: $space3());
}

// ─── Search Field ───────────────────────────────────────────────────────────

/// Search input container style for Light Mode.
InputDecoration sentraSearchDecoration({required String hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: kTextMuted, fontSize: 14),
    prefixIcon: Icon(Icons.search, color: kTextMuted, size: 20),
    filled: true,
    fillColor: kBody,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    isDense: true,
  );
}

// ─── Detail Row ─────────────────────────────────────────────────────────────

/// Text style for detail row labels.
TextStyler $detailLabel() {
  return TextStyler().color($textSecondary()).fontSize(13);
}

/// Text style for detail row values.
TextStyler $detailValue() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(13)
      .fontWeight(FontWeight.w600);
}

// ─── Stats Bar ──────────────────────────────────────────────────────────────

/// Stats bar container.
BoxStyler $statsBar() {
  return BoxStyler()
      .color($surface())
      .borderRadiusAll($radiusMd())
      .borderAll(color: $borderMuted(), width: 1)
      .paddingOnly(horizontal: $space4(), vertical: $space3());
}

// ─── Empty State ────────────────────────────────────────────────────────────

TextStyler $emptyStateText() {
  return TextStyler().color($textSecondary()).fontSize(14);
}

// ═══════════════════════════════════════════════════════════════════════════
// Typography Scales — Semantic heading/body/caption levels
// ═══════════════════════════════════════════════════════════════════════════

// ─── Heading Levels ─────────────────────────────────────────────────────────

/// Display heading — largest, used for page titles.
TextStyler $headingDisplay() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(32)
      .fontWeight(FontWeight.w700);
}

/// XL heading — section titles.
TextStyler $headingXl() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(28)
      .fontWeight(FontWeight.w700);
}

/// Large heading — subsection titles.
TextStyler $headingLg() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(24)
      .fontWeight(FontWeight.w700);
}

/// Medium heading — card titles, list section headers.
TextStyler $headingMd() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(20)
      .fontWeight(FontWeight.w600);
}

/// Small heading — form labels, widget titles.
TextStyler $headingSm() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(16)
      .fontWeight(FontWeight.w600);
}

// ─── Body Levels ────────────────────────────────────────────────────────────

/// Large body — primary content text.
TextStyler $bodyLg() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(16)
      .fontWeight(FontWeight.w400);
}

/// Regular body — default content text.
TextStyler $bodyMd() {
  return TextStyler()
      .color($textPrimary())
      .fontSize(14)
      .fontWeight(FontWeight.w400);
}

/// Small body — secondary content, descriptions.
TextStyler $bodySm() {
  return TextStyler()
      .color($textSecondary())
      .fontSize(13)
      .fontWeight(FontWeight.w400);
}

// ─── Caption Levels ─────────────────────────────────────────────────────────

/// Large caption — timestamps, metadata, hints (subtle).
TextStyler $captionLg() {
  return TextStyler()
      .color($textMuted())
      .fontSize(12)
      .fontWeight(FontWeight.w400);
}

/// Small caption — fine print, secondary metadata.
TextStyler $captionSm() {
  return TextStyler()
      .color($textMuted())
      .fontSize(11)
      .fontWeight(FontWeight.w400);
}

// ═══════════════════════════════════════════════════════════════════════════
// Form Field Styling
// ═══════════════════════════════════════════════════════════════════════════

/// Default form field decoration.
InputDecoration sentraFieldDecoration({
  required String label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? error,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: kTextSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintText: hint,
    hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    errorText: error,
    filled: true,
    fillColor: kBody,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorderMuted, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBrand, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kCritical, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    isDense: true,
  );
}

/// Compact form field (reduced padding for dense forms).
InputDecoration sentraFieldDecorationCompact({
  required String label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: kTextSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    hintText: hint,
    hintStyle: const TextStyle(color: kTextMuted, fontSize: 12),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: kBody,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: kBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: kBorderMuted, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: kBrand, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    isDense: true,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Button Styling Functions
// ═══════════════════════════════════════════════════════════════════════════

/// Primary button (brand color, large size).
ButtonStyle sentraPrimaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: kBrand,
    foregroundColor: kTextInverse,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );
}

/// Secondary button (neutral, outlined or ghost).
ButtonStyle sentraSecondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: kTextPrimary,
    side: const BorderSide(color: kBorder, width: 1),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );
}

/// Danger button (critical color).
ButtonStyle sentraDangerButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: kCritical,
    foregroundColor: kTextInverse,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );
}

/// Ghost button (minimal, text-only appearance).
ButtonStyle sentraGhostButtonStyle() {
  return TextButton.styleFrom(
    foregroundColor: kBrand,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );
}

/// Compact button (small size for dense layouts).
ButtonStyle sentraCompactButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: kBrand,
    foregroundColor: kTextInverse,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Icon Sizing Scale
// ═══════════════════════════════════════════════════════════════════════════

/// Small icon size (16px) — used in compact UI elements.
const double kIconSizeSm = 16;

/// Medium icon size (24px) — default icon size.
const double kIconSizeMd = 24;

/// Large icon size (32px) — used in prominent positions.
const double kIconSizeLg = 32;

/// XL icon size (40px) — used in hero sections.
const double kIconSizeXl = 40;

// ═══════════════════════════════════════════════════════════════════════════
// Component Wrappers (Reusable UI building blocks)
// ═══════════════════════════════════════════════════════════════════════════

/// Reusable form section wrapper with label and error state.
class FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  final String? error;
  final bool required;

  const FormSection({
    super.key,
    required this.label,
    required this.child,
    this.error,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: kCritical, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error!, style: const TextStyle(color: kCritical, fontSize: 12)),
        ],
      ],
    );
  }
}

/// Reusable list item card — used in work orders, assets, inspections lists.
class ListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? metadata;
  final Color? statusColor;
  final String? statusLabel;
  final VoidCallback? onTap;

  const ListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.metadata,
    this.statusColor,
    this.statusLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorderMuted),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (statusLabel != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (statusColor ?? kInfo).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel!,
                      style: TextStyle(
                        color: statusColor ?? kInfo,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (metadata != null && metadata!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 12, runSpacing: 8, children: metadata!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable detail row — for key-value pairs in detail screens.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final bool copyable;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style:
                  labelStyle ??
                  const TextStyle(color: kTextSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onLongPress: copyable
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied "$value"')),
                      );
                    }
                  : null,
              child: Text(
                value,
                style:
                    valueStyle ??
                    const TextStyle(
                      color: kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
