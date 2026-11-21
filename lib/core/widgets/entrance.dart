import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension EntranceX on Widget {
  /// Fade + slight upward slide, staggered by [index] (capped so long lists stay snappy).
  Widget entrance({int index = 0}) => animate(delay: (45 * index.clamp(0, 5)).ms)
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
}
