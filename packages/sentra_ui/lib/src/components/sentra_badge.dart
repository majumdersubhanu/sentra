import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import '../tokens/sentra_colors.dart';
import '../tokens/sentra_spacing.dart';
import '../tokens/sentra_typography.dart';

enum SentraBadgeType { success, warning, error, info, neutral }

class SentraBadge extends StatelessWidget {
  final String label;
  final SentraBadgeType type;

  const SentraBadge({
    super.key,
    required this.label,
    this.type = SentraBadgeType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final bgColor = color.withValues(alpha: 0.1);

    final style = BoxStyler()
        .color(bgColor)
        .paddingOnly(horizontal: SentraSpacing.s, vertical: SentraSpacing.xxs)
        .borderRadiusAll(const Radius.circular(SentraSpacing.xxl))
        .borderAll(color: color.withValues(alpha: 0.2), width: 1);

    return Box(
      style: style,
      child: Text(
        label.toUpperCase(),
        style: SentraTypography.label.copyWith(fontSize: 10, color: color),
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case SentraBadgeType.success:
        return SentraColors.success;
      case SentraBadgeType.warning:
        return SentraColors.warning;
      case SentraBadgeType.error:
        return SentraColors.error;
      case SentraBadgeType.info:
        return SentraColors.info;
      case SentraBadgeType.neutral:
        return SentraColors.gray500;
    }
  }
}
