import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'category_icons.dart';

/// Illustrated category picture (`assets/categories/<id>.png`).
/// Special ids: `deals` and `all`. Falls back to an icon if the file is missing.
class CategoryArt extends StatelessWidget {
  const CategoryArt({super.key, required this.id, this.cacheWidth = 320});

  final String id;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Image.asset(
      'assets/categories/$id.png',
      fit: BoxFit.contain,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Center(child: Icon(categoryIcon(id), size: 36, color: c.muted)),
    );
  }
}
