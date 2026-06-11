import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
            ),
            Text(
              LocaleKey.settingsTitle.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.h4(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
