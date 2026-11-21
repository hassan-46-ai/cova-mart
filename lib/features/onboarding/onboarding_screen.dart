import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/language_toggle.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) context.go('/login');
  }

  void _next(int count) {
    if (_page == count - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      (Icons.shopping_bag_rounded, l10n.onboardingTitle1, l10n.onboardingBody1),
      (Icons.local_cafe_rounded, l10n.onboardingTitle2, l10n.onboardingBody2),
      (Icons.location_on_rounded, l10n.onboardingTitle3, l10n.onboardingBody3),
    ];
    final last = _page == pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                child: Row(
                  children: [
                    const LanguageToggle(),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: last ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: last ? null : _finish,
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                        child: Text(l10n.skip),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => _OnboardingPage(icon: pages[i].$1, title: pages[i].$2, body: pages[i].$3),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: i == _page ? AppColors.cyan : Colors.white24,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: AppButton(
                  onDark: true,
                  label: last ? l10n.getStarted : l10n.next,
                  icon: Icons.arrow_forward,
                  onPressed: () => _next(pages.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Center(child: _Art(icon: icon))),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 32, height: 1.2, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 16, height: 1.55),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// Abstract brand artwork: concentric cyan rings around a floating tile.
class _Art extends StatelessWidget {
  const _Art({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    Widget ring(double size, int alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cyan.withAlpha(alpha), width: 1.2),
          ),
        );

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring(300, 28),
          ring(224, 50),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cyan, Color(0xFF1FC9C2)],
              ),
              boxShadow: [BoxShadow(color: AppColors.cyan.withAlpha(90), blurRadius: 50, spreadRadius: 2)],
            ),
            child: Icon(icon, size: 70, color: AppColors.black),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -8, end: 8, duration: 2200.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}
