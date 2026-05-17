import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../tokens/sentra_colors.dart';
import '../tokens/sentra_spacing.dart';
import '../tokens/sentra_typography.dart';

class SentraTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const SentraTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  State<SentraTextField> createState() => _SentraTextFieldState();
}

class _SentraTextFieldState extends State<SentraTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: SentraTypography.label.copyWith(color: SentraColors.gray700),
        ),
        const SizedBox(height: SentraSpacing.xs),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: SentraTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: SentraTypography.bodyMedium.copyWith(
              color: SentraColors.gray500,
            ),
            filled: true,
            fillColor: SentraColors.gray50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SentraSpacing.m,
              vertical: SentraSpacing.s,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: SentraColors.gray500,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
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
