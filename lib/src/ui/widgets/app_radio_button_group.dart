import 'package:flutter/material.dart';
import 'package:shareprompt/src/extensions/int_extensions.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class AppRadioButtonGroup extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onChanged;
  final Axis direction;
  final Color? activeColor;

  const AppRadioButtonGroup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final radioButtons = options.map((option) {
      final bool isSelected = selectedOption == option;

      return InkWell(
        onTap: () => onChanged(option),
        child: Padding(
          padding: 8.paddingVertical,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? activeColor ?? AppColors.primary
                          : AppColors.colorB8BCC6,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: 3.paddingAll,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? activeColor ?? AppColors.primary
                            : AppColors.transparent,
                      ),
                    ),
                  ),
                ),
              ),

              6.width,

              Expanded(
                child: Padding(
                  padding: 2.paddingBottom,
                  child: Text(
                    option,
                    softWrap: true,
                    maxLines: null,
                    style: AppStyles.bodyLarge(
                      color: AppColors.color333333,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: radioButtons,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: radioButtons
          .map((e) => Expanded(child: e))
          .toList(growable: false),
    );
  }
}
