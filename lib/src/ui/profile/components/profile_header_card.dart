import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.username,
    required this.postsCount,
    required this.savedCount,
    required this.onEditUsername,
    this.onBackTap,
    this.onSettingsTap,
  });

  final String username;
  final int postsCount;
  final int savedCount;
  final VoidCallback onEditUsername;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 44,
          child: Row(
            children: <Widget>[
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBackTap ?? () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    LocaleKey.profileTitle.tr,
                    style: AppStyles.h5(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
              _HeaderIconButton(
                icon: Icons.settings_outlined,
                onTap: onSettingsTap,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.profilePanel.withAlpha(145),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.profileDivider.withAlpha(120)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.bodyLarge(
                                color: AppColors.white,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkResponse(
                            onTap: onEditUsername,
                            radius: 18,
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.edit_outlined,
                                color: AppColors.profileMutedText,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _ProfileStat(
                      value: postsCount,
                      label: LocaleKey.profilePosts.tr,
                    ),
                    const SizedBox(width: 18),
                    _ProfileStat(
                      value: savedCount,
                      label: LocaleKey.profileSaved.tr,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value.toString(),
          style: AppStyles.bodyMedium(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppStyles.bodySmall(
            color: AppColors.profileMutedText,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    );
  }
}
