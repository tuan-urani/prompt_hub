import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/platform_type.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class PromptPlatformDropdown extends StatelessWidget {
  const PromptPlatformDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = PlatformType.labels.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      items: PlatformType.labels
          .map(
            (String platform) => DropdownMenuItem<String>(
              value: platform,
              child: Text(platform),
            ),
          )
          .toList(growable: false),
      onChanged: (String? value) {
        if (value != null) onChanged(value);
      },
      style: AppStyles.bodyMedium(color: AppColors.black),
      decoration: InputDecoration(
        hintText: LocaleKey.selectPlatform.tr,
        hintStyle: AppStyles.bodyMedium(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
