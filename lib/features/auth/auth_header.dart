import 'package:flutter/material.dart';

import '../../core/widgets/cova_header.dart';
import '../../core/widgets/cova_logo.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/language_toggle.dart';
import '../../core/widgets/round_icon_button.dart';

/// Black branded top section shared by login and sign-up.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle, this.showBack = false});

  final String title;
  final String subtitle;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return CovaHeader(
      bottomPadding: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack) const AppBackButton(onDark: true),
              const Spacer(),
              const LanguageToggle(),
            ],
          ),
          const SizedBox(height: 14),
          Center(child: const CovaLogo(height: 110).entrance()),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
          ).entrance(index: 1),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 15, height: 1.5),
          ).entrance(index: 2),
        ],
      ),
    );
  }
}
