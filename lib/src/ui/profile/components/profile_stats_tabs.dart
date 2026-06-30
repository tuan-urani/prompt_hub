import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

enum ProfileTab { posts, saved }

class ProfileStatsTabs extends StatelessWidget {
  const ProfileStatsTabs({
    super.key,
    required this.postsCount,
    required this.savedCount,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final int postsCount;
  final int savedCount;
  final ProfileTab selectedTab;
  final ValueChanged<ProfileTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.profileDivider, width: 1),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _ProfileTabButton(
                  label: '${LocaleKey.profilePosts.tr}($postsCount)',
                  isSelected: selectedTab == ProfileTab.posts,
                  onTap: () => onTabChanged(ProfileTab.posts),
                ),
              ),
              Expanded(
                child: _ProfileTabButton(
                  label: '${LocaleKey.profileSaved.tr}($savedCount)',
                  isSelected: selectedTab == ProfileTab.saved,
                  onTap: () => onTabChanged(ProfileTab.saved),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTabButton extends StatelessWidget {
  const _ProfileTabButton({
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
      child: SizedBox(
        height: 46,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodyLarge(
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.profileMutedText,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 2,
              width: double.infinity,
              color: isSelected
                  ? AppColors.primaryLight
                  : AppColors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
