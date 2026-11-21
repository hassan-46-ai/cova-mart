import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// Hosts the four tabs and the floating bottom bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: CovaBottomBar(
        index: shell.currentIndex,
        onSelect: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

class CovaBottomBar extends StatelessWidget {
  const CovaBottomBar({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final items = [
      (Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      (Icons.grid_view_outlined, Icons.grid_view_rounded, l10n.navCategories),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, l10n.navFavourites),
      (Icons.more_horiz_rounded, Icons.more_horiz_rounded, l10n.navMore),
    ];

    return Container(
      color: c.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: c.line),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: items[i].$1,
                      activeIcon: items[i].$2,
                      label: items[i].$3,
                      active: i == index,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelect(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: active ? 0 : 1,
            duration: const Duration(milliseconds: 160),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: c.muted),
                const SizedBox(height: 3),
                Text(label, style: TextStyle(fontSize: 11, color: c.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          AnimatedScale(
            scale: active ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.fab,
                  border: Border.all(color: c.card, width: 5),
                  boxShadow: [BoxShadow(color: AppColors.cyan.withAlpha(70), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Icon(activeIcon, size: 25, color: c.onFab),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
