import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'category_icons.dart';

/// Product photo from the asset bundle. While a photo is missing it shows an
/// elegant neutral tile, so the UI never breaks.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    required this.categoryId,
    this.fit = BoxFit.cover,
    this.cacheWidth = 420,
  });

  final String path;
  final String categoryId;
  final BoxFit fit;

  /// Decode width in pixels. Small tiles never need the full-size photo.
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: fit,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      width: double.infinity,
      height: double.infinity,
      frameBuilder: (context, child, frame, sync) {
        if (sync) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => ImagePlaceholder(categoryId: categoryId),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.cardAlt, c.line],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          final iconSize = (side.isFinite ? side * 0.26 : 34.0).clamp(12.0, 40.0).toDouble();
          return Center(
            child: Container(
              padding: EdgeInsets.all(iconSize * 0.45),
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.card.withAlpha(150)),
              child: Icon(categoryIcon(categoryId), size: iconSize, color: c.muted.withAlpha(170)),
            ),
          );
        },
      ),
    );
  }
}
