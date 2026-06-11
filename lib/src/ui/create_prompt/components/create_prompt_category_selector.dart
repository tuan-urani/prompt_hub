import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class CreatePromptCategorySelector extends StatelessWidget {
  const CreatePromptCategorySelector({
    super.key,
    required this.selectedCategories,
    required this.onCategoryToggled,
  });

  final List<PromptCategory> selectedCategories;
  final ValueChanged<PromptCategory> onCategoryToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              LocaleKey.createPromptCategoryLabel.tr,
              style: AppStyles.bodyLarge(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              LocaleKey.createPromptCategoryOptional.tr,
              style: AppStyles.bodySmall(
                color: AppColors.createPromptMutedText,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.createPromptMutedText,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 36,
          child: ListView.separated(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: PromptCategory.selectable.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final category = PromptCategory.selectable[index];
              return _CreatePromptCategoryChip(
                label: _labelFor(category),
                isSelected: _isSelected(category),
                onTap: () => onCategoryToggled(category),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSelected(PromptCategory category) {
    if (category == PromptCategory.all) return selectedCategories.isEmpty;
    return selectedCategories.contains(category);
  }

  String _labelFor(PromptCategory category) {
    return switch (category) {
      PromptCategory.all => LocaleKey.categoryAll.tr,
      PromptCategory.people => LocaleKey.categoryPeople.tr,
      PromptCategory.animals => LocaleKey.categoryAnimals.tr,
      PromptCategory.fashion => LocaleKey.categoryFashion.tr,
      PromptCategory.sports => LocaleKey.categorySports.tr,
    };
  }
}

class _CreatePromptCategoryChip extends StatelessWidget {
  const _CreatePromptCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.transparent
              : AppColors.discoveryChipFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.discoveryPurple
                : AppColors.createPromptChipBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall(
            color: isSelected ? AppColors.discoveryPurple : AppColors.white,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
