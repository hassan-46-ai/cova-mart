import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';
import 'entrance.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.cardAlt),
              child: Icon(icon, size: 42, color: c.muted),
            ),
            const SizedBox(height: 22),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: c.muted, height: 1.5)),
            if (actionLabel != null) ...[
              const SizedBox(height: 26),
              SizedBox(width: 220, child: AppButton(label: actionLabel!, onPressed: onAction)),
            ],
          ],
        ).entrance(),
      ),
    );
  }
}
