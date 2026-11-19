import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension EntranceX on Widget {
  /// Fade + slight upward slide, staggered by [index] (capped so long lists stay snappy).
  Widget entrance({int index = 0}) => animate(delay: (55 * index.clamp(0, 8)).ms)
      .fadeIn(duration: 380.ms)
      .slideY(begin: 0.06, end: 0, duration: 380.ms, curve: Curves.easeOutCubic);
}
