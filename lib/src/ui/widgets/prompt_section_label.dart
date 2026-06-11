import 'package:flutter/material.dart';

import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class PromptSectionLabel extends StatelessWidget {
  const PromptSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppStyles.bodySmall(
        color: AppColors.black,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
