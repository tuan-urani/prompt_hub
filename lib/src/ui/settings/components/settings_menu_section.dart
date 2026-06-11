import 'package:flutter/material.dart';

import 'package:shareprompt/src/extensions/int_extensions.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class SettingsMenuSection extends StatelessWidget {
  const SettingsMenuSection({
    super.key,
    required this.children,
    this.isDanger = false,
  });

  final List<Widget> children;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDanger
            ? AppColors.settingsDangerPanel
            : AppColors.settingsPanel,
        borderRadius: 14.borderRadiusAll,
        border: Border.all(
          color: isDanger
              ? AppColors.settingsDangerBorder
              : AppColors.settingsPanelBorder,
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class SettingsMenuItem extends StatelessWidget {
  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.isDanger = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDanger;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDanger
        ? AppColors.settingsDanger
        : AppColors.discoveryPurple;
    final textColor = isDanger ? AppColors.settingsDanger : AppColors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              Icon(icon, color: iconColor, size: 28),
              20.width,
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.h5(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              ?trailing,
              if (showChevron) ...<Widget>[
                12.width,
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.settingsChevron,
                  size: 30,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsMenuDivider extends StatelessWidget {
  const SettingsMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: ColoredBox(color: AppColors.settingsDivider),
      ),
    );
  }
}

class SettingsLanguagePill extends StatelessWidget {
  const SettingsLanguagePill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.settingsLanguagePill,
        borderRadius: 24.borderRadiusAll,
        border: Border.all(color: AppColors.settingsPanelBorder),
      ),
      child: SizedBox(
        height: 48,
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodyLarge(
                  color: AppColors.profileWhiteMuted,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
            8.width,
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.settingsChevron,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
