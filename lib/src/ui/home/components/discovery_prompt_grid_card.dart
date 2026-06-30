import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/ui/home/bloc/home_bloc.dart';
import 'package:shareprompt/src/ui/home/components/prompt_preview_modal.dart';
import 'package:shareprompt/src/ui/widgets/prompt_image_view.dart';
import 'package:shareprompt/src/utils/app_colors.dart';

class DiscoveryPromptGridCard extends StatelessWidget {
  const DiscoveryPromptGridCard({super.key, required this.prompt, this.onTap});

  final Prompt prompt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () async {
            final shouldRefresh = await showPromptPreviewModal(
              context: context,
              prompt: prompt,
            );
            if (shouldRefresh == true) {
              Get.find<HomeBloc>().refresh();
            }
          },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.discoveryCardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: SizedBox.expand(
            child: PromptImageView(
              url: prompt.imageUrl,
              radius: 0,
              placeholderColor: AppColors.discoveryChipFill,
              placeholderIconColor: AppColors.discoveryTextMuted,
              loadingColor: AppColors.discoveryPurple,
            ),
          ),
        ),
      ),
    );
  }
}
