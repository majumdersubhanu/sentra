import 'package:flutter/material.dart';
import 'sentra_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Professional Reusable Components — Production-grade widgets
// ═══════════════════════════════════════════════════════════════════════════

// ─── Dialog Component ───────────────────────────────────────────────────────

/// Professional dialog wrapper with consistent styling.
class SentraDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? content;
  final List<Widget>? actions;
  final bool showCloseButton;

  const SentraDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.actions,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderMuted, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
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
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: kTextSecondary,
                    ),
                ],
              ),
            ),
            // Content
            if (content != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: content,
              ),
              const SizedBox(height: 24),
            ],
            // Actions
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 12,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Dropdown Component ─────────────────────────────────────────────────────

/// Professional dropdown with consistent styling.
class SentraDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? error;
  final bool required;

  const SentraDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.error,
    this.required = false,
  });

  @override
  State<SentraDropdown<T>> createState() => _SentraDropdownState<T>();
}

class _SentraDropdownState<T> extends State<SentraDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.required)
              const Text(
                ' *',
                style: TextStyle(color: kCritical, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.error != null ? kCritical : kBorderMuted,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<T>(
            value: widget.value,
            hint: widget.hint != null
                ? Text(widget.hint!, style: const TextStyle(color: kTextMuted))
                : null,
            items: widget.items,
            onChanged: widget.onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.error!,
            style: const TextStyle(color: kCritical, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

// ─── Tab Component ─────────────────────────────────────────────────────────

/// Professional tab bar with indicator.
class SentraTabBar extends StatefulWidget {
  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int> onTabChanged;

  const SentraTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    required this.onTabChanged,
  });

  @override
  State<SentraTabBar> createState() => _SentraTabBarState();
}

class _SentraTabBarState extends State<SentraTabBar> {
  late int _selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              widget.tabs.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  widget.onTabChanged(index);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        widget.tabs[index],
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? kBrand
                              : kTextSecondary,
                          fontSize: 14,
                          fontWeight: _selectedIndex == index
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_selectedIndex == index)
                      Container(
                        height: 3,
                        width: 50,
                        decoration: BoxDecoration(
                          color: kBrand,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(height: 1, color: kBorderMuted),
      ],
    );
  }
}

// ─── Badge Component ────────────────────────────────────────────────────────

/// Professional badge/chip component.
class SentraBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onRemove;
  final IconData? icon;

  const SentraBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.onRemove,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (icon != null) Icon(icon, color: textColor, size: 16),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, color: textColor, size: 16),
            ),
        ],
      ),
    );
  }
}

// ─── Status Indicator ───────────────────────────────────────────────────────

/// Status indicator with label and optional icon.
class StatusIndicator extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusIndicator({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(icon, color: color, size: 16),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────

/// Section header for detail screens.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Row(
        spacing: 8,
        children: [
          if (icon != null) Icon(icon, color: kBrand, size: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(color: kTextSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

/// Professional empty state component.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: kBorderMuted),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: kTextSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}

// ─── Loading Skeleton ───────────────────────────────────────────────────────

/// Loading skeleton placeholder.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: kBody,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.1, 0.5, 0.9],
            colors: [kBody, kBorderMuted, kBody],
            tileMode: TileMode.clamp,
          ).createShader(Offset.zero & bounds.size);
        },
        child: Container(color: kBody),
      ),
    );
  }
}

// ─── Divider ───────────────────────────────────────────────────────────────

/// Professional divider with optional label.
class SentraDivider extends StatelessWidget {
  final String? label;
  final EdgeInsets padding;

  const SentraDivider({
    super.key,
    this.label,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Padding(
        padding: padding,
        child: Divider(color: kBorderMuted, height: 1),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Divider(color: kBorderMuted)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: kBorderMuted)),
        ],
      ),
    );
  }
}

// ─── Info Box ───────────────────────────────────────────────────────────────

/// Information/alert box component.
class InfoBox extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const InfoBox({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.05),
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 12,
        children: [
          if (icon != null) Icon(icon, color: textColor, size: 20),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: textColor, size: 16),
            ),
        ],
      ),
    );
  }
}
