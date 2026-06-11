import 'package:flutter/material.dart';

import 'package:shareprompt/src/utils/app_colors.dart';

class DiscoveryBackground extends StatelessWidget {
  const DiscoveryBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.discoveryBackgroundGradient(),
      ),
      child: child,
    );
  }
}
