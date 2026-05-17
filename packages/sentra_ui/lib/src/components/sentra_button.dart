import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import '../tokens/sentra_colors.dart';
import '../tokens/sentra_spacing.dart';
import '../tokens/sentra_typography.dart';

class SentraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Widget? icon;

  const SentraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = Style(
      text.style(SentraTypography.label),
      text.color(isPrimary ? Colors.white : SentraColors.primary700),
      container.color(isPrimary ? SentraColors.primary700 : Colors.white),
      container.padding.symmetric(
        horizontal: SentraSpacing.m,
        vertical: SentraSpacing.s,
      ),
      container.border.all(
        color: isPrimary ? Colors.transparent : SentraColors.primary700,
        width: 1,
      ),
      container.borderRadius(SentraSpacing.xs),
      // Hover/Press states
      onHover(
        container.color(
          isPrimary ? SentraColors.primary900 : SentraColors.primary50,
        ),
      ),
      onPress(container.scale(0.98)),
    );

    return PressableBox(
      onPress: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: SentraSpacing.xs)],
          StyledText(label),
        ],
      ),
    );
  }
}
