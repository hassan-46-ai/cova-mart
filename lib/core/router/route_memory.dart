/// Which screens the app may re-open after it was closed.
/// (Login, onboarding, the map picker and the order-success page are never restored.)
abstract final class RouteMemory {
  static const tabs = {'/home', '/categories', '/favorites', '/more'};

  static bool isResumable(String path) =>
      tabs.contains(path) ||
      path.startsWith('/category/') ||
      path.startsWith('/product/') ||
      path.startsWith('/order/') ||
      const {'/search', '/cart', '/checkout', '/orders', '/addresses', '/profile/edit'}.contains(path);
}
