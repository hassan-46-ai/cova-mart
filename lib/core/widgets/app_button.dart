import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.outlined = false,
    this.onDark = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool outlined;

  /// Cyan button for black backgrounds (splash, onboarding, auth header).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spinnerColor = onDark ? AppColors.black : (outlined ? scheme.primary : scheme.onPrimary);

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: spinnerColor),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (icon != null) ...[
                  const SizedBox(width: 10),
                  Icon(icon, size: 20),
                ],
              ],
            ),
    );

    final VoidCallback? handler = (onPressed == null || loading)
        ? null
        : () {
            HapticFeedback.selectionClick();
            onPressed!();
          };

    return outlined
        ? OutlinedButton(onPressed: handler, child: child)
        : FilledButton(
            onPressed: handler,
            style: onDark
                ? FilledButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: AppColors.black)
                : null,
            child: child,
          );
  }
}
