import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import '../tokens/sentra_colors.dart';
import '../tokens/sentra_spacing.dart';

class SentraCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const SentraCard({super.key, required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    final style = Style(
      container.color(Colors.white),
      container.padding(padding ?? const EdgeInsets.all(SentraSpacing.m)),
      container.borderRadius(SentraSpacing.s),
      container.border.all(color: SentraColors.gray200, width: 1),
      container.boxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
      onHover(container.border.color(SentraColors.primary500)),
    );

    if (onTap != null) {
      return PressableBox(onPress: onTap, style: style, child: child);
    }

    return Box(style: style, child: child);
  }
}
