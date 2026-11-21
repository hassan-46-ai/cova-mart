import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/local_store.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/categories/category_products_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_success_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/addresses_screen.dart';
import '../../features/map/map_picker_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/orders/order_tracking_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/product/product_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/more_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../providers/app_providers.dart';
import 'route_memory.dart';

CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRoute _route(String path, Widget Function(GoRouterState state) builder) =>
    GoRoute(path: path, pageBuilder: (context, state) => _page(state, builder(state)));

final routerProvider = Provider<GoRouter>((ref) {
  // Make the router's location follow push()/pop() too, so we can remember it.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final store = ref.read(localStoreProvider);

  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      _route('/splash', (_) => const SplashScreen()),
      _route('/onboarding', (_) => const OnboardingScreen()),
      _route('/login', (_) => const LoginScreen()),
      _route('/signup', (_) => const SignupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (_, __) => const MoreScreen())]),
        ],
      ),
      _route('/category/:id', (s) => CategoryProductsScreen(categoryId: s.pathParameters['id']!)),
      _route('/product/:id', (s) => ProductScreen(productId: s.pathParameters['id']!)),
      _route('/search', (_) => const SearchScreen()),
      _route('/cart', (_) => const CartScreen()),
      _route('/checkout', (_) => const CheckoutScreen()),
      _route('/order-success/:id', (s) => OrderSuccessScreen(orderId: s.pathParameters['id']!)),
      _route('/orders', (_) => const OrdersScreen()),
      _route('/order/:id', (s) => OrderTrackingScreen(orderId: s.pathParameters['id']!)),
      _route('/addresses', (s) => AddressesScreen(pickMode: s.extra == 'pick')),
      _route('/map-picker', (s) => MapPickerScreen(args: s.extra as MapPickerArgs?)),
      _route('/profile/edit', (_) => const EditProfileScreen()),
    ],
  );

  // Remember the last meaningful screen so the app can reopen exactly there.
  void remember() {
    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (RouteMemory.isResumable(path)) store.writeString(StoreKeys.lastRoute, path);
  }

  // Tapping an order notification opens that order (only when signed in).
  ref.read(notificationServiceProvider).onOpen = (path) {
    if (ref.read(authProvider) != null) router.push(path);
  };

  router.routerDelegate.addListener(remember);
  ref.onDispose(() => router.routerDelegate.removeListener(remember));
  return router;
});
