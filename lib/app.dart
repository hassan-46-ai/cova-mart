import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/providers/settings_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// iOS-style bounce + no glow: feels smoother and more premium on every platform.
class CovaScrollBehavior extends MaterialScrollBehavior {
  const CovaScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class CovaApp extends ConsumerWidget {
  const CovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Cova Mart',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(settings.locale),
      darkTheme: AppTheme.dark(settings.locale),
      themeMode: settings.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 250),
      scrollBehavior: const CovaScrollBehavior(),
    );
  }
}
