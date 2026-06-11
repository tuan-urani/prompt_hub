import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/extensions/int_extensions.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/widgets/prompt_image_view.dart';
import 'package:shareprompt/src/ui/widgets/prompt_platform_chip.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class ProfilePromptCard extends StatelessWidget {
  const ProfilePromptCard({
    super.key,
    required this.prompt,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Prompt prompt;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 12.paddingBottom,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.profilePanel,
            borderRadius: 14.borderRadiusAll,
            border: Border.all(color: AppColors.profileDivider),
          ),
          child: Padding(
            padding: 10.paddingAll,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PromptImageView(
                  url: prompt.imageUrl,
                  width: 92,
                  height: 92,
                  radius: 10,
                ),
                12.width,
                Expanded(
                  child: SizedBox(
                    height: 92,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          prompt.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodyLarge(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        6.height,
                        Text(
                          prompt.prompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall(
                            color: AppColors.profileMutedText,
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        PromptPlatformChip(
                          platform: prompt.platform,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
                if (onEdit != null && onDelete != null)
                  _ProfilePromptMenu(onEdit: onEdit!, onDelete: onDelete!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePromptMenu extends StatelessWidget {
  const _ProfilePromptMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.profilePanel,
      iconColor: AppColors.profileMutedText,
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (String value) {
        if (value == 'edit') {
          onEdit();
          return;
        }
        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(
            LocaleKey.editPromptTitle.tr,
            style: AppStyles.bodyMedium(color: AppColors.white),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            LocaleKey.deletePrompt.tr,
            style: AppStyles.bodyMedium(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
