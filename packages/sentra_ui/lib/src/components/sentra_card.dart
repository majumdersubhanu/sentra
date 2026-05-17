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
    final style = BoxStyler()
        .color(Colors.white)
        .borderRadiusAll(const Radius.circular(SentraSpacing.s))
        .borderAll(color: SentraColors.gray200, width: 1);

    if (onTap != null) {
      return PressableBox(
        onPress: onTap,
        style: style,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(SentraSpacing.m),
          child: child,
        ),
      );
    }

    return Box(
      style: style,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(SentraSpacing.m),
        child: child,
      ),
    );
  }
}
