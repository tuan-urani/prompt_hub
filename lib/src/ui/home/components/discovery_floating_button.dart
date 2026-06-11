import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_pages.dart';

class DiscoveryFloatingButton extends StatelessWidget {
  const DiscoveryFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 44),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppPages.createPrompt),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.discoveryPrimaryGradient(),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.discoveryPurpleShadow.withAlpha(105),
                blurRadius: 34,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const SizedBox(
            width: 60,
            height: 60,
            child: Icon(
              Icons.add_rounded,
              color: AppColors.discoveryTextPrimary,
              size: 38,
            ),
          ),
        ),
      ),
    );
  }
}
