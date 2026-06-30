import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_assets.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_pages.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final PromptCategory selectedCategory;
  final ValueChanged<PromptCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final categories = PromptCategory.selectable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      AppAssets.discoveryHeaderPng,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _ProfileIconButton(onTap: () => Get.toNamed(AppPages.profile)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (BuildContext context, int index) {
                final category = categories[index];
                return _CategoryChip(
                  label: _labelFor(category),
                  isSelected: selectedCategory == category,
                  onTap: () => onCategorySelected(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(PromptCategory category) {
    return switch (category) {
      PromptCategory.all => LocaleKey.categoryAll.tr,
      PromptCategory.anime => LocaleKey.categoryAnime.tr,
      PromptCategory.fashion => LocaleKey.categoryFashion.tr,
      PromptCategory.conceptArt => LocaleKey.categoryConceptArt.tr,
      PromptCategory.portrait => LocaleKey.categoryPortrait.tr,
      PromptCategory.renders3d => LocaleKey.category3dRenders.tr,
    };
  }
}

class _ProfileIconButton extends StatelessWidget {
  const _ProfileIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.discoveryPurple,
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            Icons.person_outline_rounded,
            color: AppColors.discoveryTextPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
        height: 30,
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.discoveryPrimaryGradient() : null,
          color: isSelected ? null : AppColors.discoveryChipFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.transparent
                : AppColors.discoveryChipBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.discoveryPurpleShadow.withAlpha(45),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall(
            color: isSelected
                ? AppColors.discoveryTextPrimary
                : AppColors.discoveryTextMuted,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
