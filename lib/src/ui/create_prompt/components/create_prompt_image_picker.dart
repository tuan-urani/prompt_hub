import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/widgets/prompt_image_view.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class CreatePromptImagePicker extends StatelessWidget {
  const CreatePromptImagePicker({
    super.key,
    required this.bytes,
    this.imageUrl,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  final Uint8List? bytes;
  final String? imageUrl;
  final VoidCallback onAddImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.68,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: bytes == null && (imageUrl == null || imageUrl!.isEmpty)
                ? GestureDetector(
                    onTap: onAddImage,
                    child: CustomPaint(
                      painter: _DashedRoundedBorderPainter(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.createPromptField,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppColors.primaryLight,
                                size: 48,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                LocaleKey.addImage.tr,
                                style: AppStyles.bodyMedium(
                                  color: AppColors.createPromptMutedText,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: onAddImage,
                    child: PromptImageView(
                      bytes: bytes,
                      url: imageUrl,
                      radius: 16,
                    ),
                  ),
          ),
          if (bytes != null || (imageUrl != null && imageUrl!.isNotEmpty))
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onRemoveImage,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.black.withAlpha(145),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    const dashWidth = 7.0;
    const dashSpace = 7.0;
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(radius)));
    final paint = Paint()
      ..color = AppColors.createPromptDashedBorder
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final endDistance = nextDistance.clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, endDistance), paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
