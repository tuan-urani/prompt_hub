import 'package:flutter/material.dart';
import 'package:shareprompt/src/extensions/int_extensions.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class ProfileEmptyState extends StatelessWidget {
  const ProfileEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const _ProfileEmptyIcon(),
        26.height,
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppStyles.h4(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        // 20.height,
        // Text(
        //   message,
        //   textAlign: TextAlign.center,
        //   style: AppStyles.bodyLarge(
        //     color: AppColors.profileMutedText,
        //     fontWeight: FontWeight.w500,
        //     height: 1.45,
        //   ),
        // ),
        if (actionLabel != null) ...<Widget>[
          20.height,
          _ProfileActionButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );
  }
}

class _ProfileEmptyIcon extends StatelessWidget {
  const _ProfileEmptyIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Icon(
              Icons.feed_outlined,
              color: AppColors.profileEmptyIcon,
              size: 84,
            ),
          ),
          Positioned(
            top: -4,
            right: 4,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primaryLight,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(),
            borderRadius: 16.borderRadiusAll,
          ),
          child: SizedBox(
            width: 200,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.add_rounded, color: AppColors.white, size: 32),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.h5(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
