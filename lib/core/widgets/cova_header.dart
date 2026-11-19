import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Black rounded header block with a soft cyan glow (the design's blue header).
class CovaHeader extends StatelessWidget {
  const CovaHeader({super.key, required this.child, this.bottomPadding = 26});

  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, bottomPadding),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
        gradient: RadialGradient(
          center: const AlignmentDirectional(0.95, -1.1),
          radius: 1.3,
          colors: [AppColors.cyan.withAlpha(55), c.header],
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.onHeader),
        child: child,
      ),
    );
  }
}
