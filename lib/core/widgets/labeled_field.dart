import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboard;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.keyboard,
    this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
            ),
          ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.neutral400, fontSize: 13),
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: AppColors.neutral400)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.c400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}