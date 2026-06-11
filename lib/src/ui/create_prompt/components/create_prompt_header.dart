import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class CreatePromptHeader extends StatelessWidget {
  const CreatePromptHeader({
    super.key,
    this.title,
    this.actionLabel,
    required this.isSubmitting,
    required this.onClose,
    required this.onPublish,
  });

  final String? title;
  final String? actionLabel;
  final bool isSubmitting;
  final VoidCallback onClose;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      child: SizedBox(
        height: 44,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.white,
                size: 30,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title ?? LocaleKey.createPromptTitle.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.h5(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onPublish,
              behavior: HitTestBehavior.opaque,
              child: Opacity(
                opacity: isSubmitting ? 0.72 : 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: AppColors.createPromptButtonShadow,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 42,
                    width: 104,
                    child: Center(
                      child: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              actionLabel ?? LocaleKey.publish.tr,
                              style: AppStyles.bodyLarge(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
