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
    final bgColor = color.withOpacity(0.1);

    final style = Style(
      text.style(SentraTypography.label.copyWith(fontSize: 10)),
      text.color(color),
      container.color(bgColor),
      container.padding.symmetric(
        horizontal: SentraSpacing.s,
        vertical: SentraSpacing.xxs,
      ),
      container.borderRadius(SentraSpacing.xxl),
      container.border.all(color: color.withOpacity(0.2), width: 1),
    );

    return Box(style: style, child: StyledText(label.toUpperCase()));
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
