import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/cart_controller.dart';
import '../theme/app_colors.dart';
import 'pressable.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.onDark = false,
    this.size = 44,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// True when drawn on the black header.
  final bool onDark;
  final double size;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onDark ? Colors.white.withAlpha(30) : c.cardAlt,
        ),
        child: Icon(icon, size: size * 0.48, color: iconColor ?? (onDark ? Colors.white : c.text)),
      ),
    );
  }
}

/// Back button that falls back to Home when there is nothing to pop.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return RoundIconButton(
      icon: Icons.arrow_back,
      onDark: onDark,
      onTap: () => context.canPop() ? context.pop() : context.go('/home'),
    );
  }
}

/// Cart icon with a live item-count badge.
class CartButton extends ConsumerWidget {
  const CartButton({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartSummaryProvider.select((s) => s.itemCount));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RoundIconButton(
          icon: Icons.shopping_bag_outlined,
          onDark: onDark,
          onTap: () => context.push('/cart'),
        ),
        if (count > 0)
          PositionedDirectional(
            top: -4,
            end: -4,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Container(
                  key: ValueKey(count),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(color: AppColors.black, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
