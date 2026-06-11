import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/extensions/int_extensions.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/settings/components/settings_header.dart';
import 'package:shareprompt/src/ui/settings/components/settings_menu_section.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackgroundBottom,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.profileBackgroundGradient(),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: <Widget>[
                SettingsHeader(onBack: () => Navigator.pop(context)),
                26.height,
                SettingsMenuSection(
                  children: <Widget>[
                    SettingsMenuItem(
                      icon: Icons.policy_outlined,
                      label: LocaleKey.settingsPrivacyPolicy.tr,
                    ),
                    const SettingsMenuDivider(),
                    SettingsMenuItem(
                      icon: Icons.description_outlined,
                      label: LocaleKey.settingsTermsOfUse.tr,
                    ),
                  ],
                ),
                18.height,
                SettingsMenuSection(
                  children: <Widget>[
                    SettingsMenuItem(
                      icon: Icons.language_rounded,
                      label: LocaleKey.settingsLanguage.tr,
                      showChevron: false,
                      trailing: SettingsLanguagePill(
                        label: LocaleKey.settingsEnglish.tr,
                      ),
                    ),
                  ],
                ),
                18.height,
                SettingsMenuSection(
                  isDanger: true,
                  children: <Widget>[
                    SettingsMenuItem(
                      icon: Icons.delete_outline_rounded,
                      label: LocaleKey.settingsDeleteData.tr,
                      isDanger: true,
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Text(
                    '${LocaleKey.settingsAppVersion.tr} 1.0.0',
                    style: AppStyles.bodyMedium(
                      color: AppColors.createPromptMutedText,
                      fontWeight: FontWeight.w500,
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
