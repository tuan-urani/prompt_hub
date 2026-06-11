import 'package:flutter/material.dart';

import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class PromptPlatformChip extends StatelessWidget {
  const PromptPlatformChip({
    super.key,
    required this.platform,
    this.compact = false,
  });

  final String platform;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.promptLavender,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 5 : 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _iconFor(platform),
              size: compact ? 12 : 16,
              color: AppColors.black,
            ),
            SizedBox(width: compact ? 4 : 7),
            Text(
              platform,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.caption(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String value) {
    return switch (value.toLowerCase()) {
      'openai' => Icons.auto_awesome,
      'gemini' => Icons.diamond_outlined,
      'midjourney' => Icons.sailing_outlined,
      'flux' => Icons.bolt_rounded,
      _ => Icons.blur_on_rounded,
    };
  }
}
