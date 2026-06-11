import 'package:flutter/material.dart';

import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class PromptTextField extends StatelessWidget {
  const PromptTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final int minLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      style: AppStyles.bodyMedium(color: AppColors.black, height: 1.45),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppStyles.bodyMedium(color: AppColors.textSecondary),
        counterStyle: AppStyles.caption(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
