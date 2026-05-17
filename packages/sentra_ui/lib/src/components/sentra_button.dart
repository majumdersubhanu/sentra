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
    final style = BoxStyler()
        .color(isPrimary ? SentraColors.primary700 : Colors.white)
        .paddingOnly(horizontal: SentraSpacing.m, vertical: SentraSpacing.s)
        .borderAll(
          color: isPrimary ? Colors.transparent : SentraColors.primary700,
          width: 1,
        )
        .borderRadiusAll(const Radius.circular(SentraSpacing.xs));

    return PressableBox(
      onPress: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: SentraSpacing.xs)],
          Text(
            label,
            style: SentraTypography.label.copyWith(
              color: isPrimary ? Colors.white : SentraColors.primary700,
            ),
          ),
        ],
      ),
    );
  }
}
