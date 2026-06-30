import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, this.onBackTap, this.onSettingsTap});

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
