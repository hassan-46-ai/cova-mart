import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_controller.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Small "عربي / EN" pill that flips the app language instantly.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.onDark = true});

  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isAr = context.isAr;
    final fg = onDark ? Colors.white : c.text;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(settingsProvider.notifier).setLanguage(isAr ? 'en' : 'ar');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: onDark ? Colors.white.withAlpha(30) : c.cardAlt,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(isAr ? 'English' : 'عربي', style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
