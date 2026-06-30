import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:shareprompt/src/utils/app_colors.dart';

class PromptImageView extends StatelessWidget {
  const PromptImageView({
    super.key,
    this.url,
    this.bytes,
    this.width,
    this.height,
    this.radius = 10,
    this.fit = BoxFit.cover,
    this.placeholderColor = AppColors.surfaceMuted,
    this.placeholderIconColor = AppColors.textSecondary,
    this.loadingColor = AppColors.primary,
  });

  final String? url;
  final Uint8List? bytes;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;
  final Color placeholderColor;
  final Color placeholderIconColor;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (bytes != null) {
      child = Image.memory(bytes!, width: width, height: height, fit: fit);
    } else if (url != null && url!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        cacheKey: url!,
        placeholder: (_, _) => ColoredBox(color: placeholderColor),
        errorWidget: (_, _, _) => ColoredBox(
          color: placeholderColor,
          child: Icon(Icons.broken_image_outlined, color: placeholderIconColor),
        ),
      );
    } else {
      child = ColoredBox(
        color: placeholderColor,
        child: Center(
          child: Icon(Icons.image_outlined, color: placeholderIconColor),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}
