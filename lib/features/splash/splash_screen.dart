import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_controller.dart';
import '../../core/router/route_memory.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cova_logo.dart';
import '../../data/services/local_store.dart';
import '../auth/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _duration = Duration(milliseconds: 2400);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_duration, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final seen = ref.read(settingsProvider).onboardingSeen;
    final user = ref.read(authProvider);
    if (!seen) {
      context.go('/onboarding');
    } else if (user == null) {
      context.go('/login');
    } else {
      _resume();
    }
  }

  /// Re-open the screen the user was on when the app was closed.
  void _resume() {
    final saved = ref.read(localStoreProvider).readString(StoreKeys.lastRoute);
    final router = GoRouter.of(context);
    if (saved == null || saved == '/home') {
      router.go('/home');
    } else if (RouteMemory.tabs.contains(saved)) {
      router.go(saved);
    } else {
      // Deeper screen: build the stack Home -> saved, so the back button still works.
      router.go('/home');
      WidgetsBinding.instance.addPostFrameCallback((_) => router.push(saved));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget ring({required int delayMs}) => Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cyan.withAlpha(150), width: 1.4),
          ),
        )
            .animate(delay: delayMs.ms, onPlay: (c) => c.repeat())
            .scale(begin: const Offset(0.55, 0.55), end: const Offset(1.6, 1.6), duration: 2200.ms, curve: Curves.easeOut)
            .fadeOut(duration: 2200.ms);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
         child: Stack(
          alignment: Alignment.center,
          children: [
            ring(delayMs: 0),
            ring(delayMs: 1100),
            const CovaLogo(height: 200)
                .animate()
                .fadeIn(duration: 700.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 900.ms, curve: Curves.easeOutBack),
            Positioned(
              bottom: 96,
              child: Text(
                context.l10n.splashTagline,
                style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 14, letterSpacing: 0.4),
              ).animate(delay: 900.ms).fadeIn(duration: 600.ms).slideY(begin: 0.4, end: 0, duration: 600.ms),
            ),
            Positioned(
              bottom: 56,
              child: SizedBox(
                width: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: _duration,
                  curve: Curves.easeInOut,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: Colors.white.withAlpha(30),
                    color: AppColors.cyan,
                  ),
                ),
              ),
            ),
          ],
         ),
        ),
      ),
    );
  }
}
