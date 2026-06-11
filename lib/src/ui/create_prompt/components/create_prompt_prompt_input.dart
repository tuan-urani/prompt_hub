import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class CreatePromptInput extends StatelessWidget {
  const CreatePromptInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  static const int maxLength = 2000;

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 274,
      child: Stack(
        children: <Widget>[
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: null,
            maxLines: null,
            expands: true,
            maxLength: maxLength,
            textAlignVertical: TextAlignVertical.top,
            style: AppStyles.bodyMedium(color: AppColors.white, height: 1.45),
            decoration: InputDecoration(
              hintText: LocaleKey.promptHint.tr,
              hintStyle: AppStyles.bodyMedium(
                color: AppColors.createPromptMutedText,
              ),
              counterText: '',
              filled: true,
              fillColor: AppColors.createPromptField,
              contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.createPromptFieldBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.primaryLight),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 16,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, TextEditingValue value, _) {
                return Text(
                  '${value.text.length}/$maxLength',
                  style: AppStyles.bodyMedium(
                    color: AppColors.createPromptMutedText,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
