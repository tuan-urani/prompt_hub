import 'package:flutter/material.dart';

import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class PromptPrimaryButton extends StatelessWidget {
  const PromptPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDanger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final color = isDanger ? AppColors.error : AppColors.primary;
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, color: isOutlined ? color : AppColors.white, size: 20),
        if (icon != null || isLoading) const SizedBox(width: 8),
        Text(
          label,
          style: AppStyles.bodyMedium(
            color: isOutlined ? color : AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isOutlined || isDanger
                ? null
                : AppColors.primaryGradient(),
            color: isOutlined || isDanger ? AppColors.white : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
