import 'package:flutter/material.dart';
import '../tokens/sentra_colors.dart';
import '../tokens/sentra_spacing.dart';
import '../tokens/sentra_typography.dart';

class SentraTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const SentraTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SentraTypography.label.copyWith(color: SentraColors.gray700),
        ),
        const SizedBox(height: SentraSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: SentraTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: SentraTypography.bodyMedium.copyWith(
              color: SentraColors.gray500,
            ),
            filled: true,
            fillColor: SentraColors.gray50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SentraSpacing.m,
              vertical: SentraSpacing.s,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SentraSpacing.xs),
              borderSide: const BorderSide(color: SentraColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SentraSpacing.xs),
              borderSide: const BorderSide(color: SentraColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SentraSpacing.xs),
              borderSide: const BorderSide(
                color: SentraColors.primary500,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SentraSpacing.xs),
              borderSide: const BorderSide(color: SentraColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
