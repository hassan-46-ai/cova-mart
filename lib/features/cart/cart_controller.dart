import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/models/cart.dart';
import '../../data/services/local_store.dart';
import '../auth/auth_controller.dart';

class CartState {
  const CartState({this.items = const {}, this.promo});

  final Map<String, int> items;
  final String? promo;
}

class CartController extends Notifier<CartState> {
  late String _key;

  @override
  CartState build() {
    _key = StoreKeys.cart(ref.watch(userIdProvider));
    final raw = ref.read(localStoreProvider).readJson(_key);
    if (raw is! Map) return const CartState();
    return CartState(
      items: (raw['items'] as Map).map((k, v) => MapEntry(k as String, (v as num).toInt())),
      promo: raw['promo'] as String?,
    );
  }

  int qtyOf(String id) => state.items[id] ?? 0;

  void add(String id, {int qty = 1}) => _set({...state.items, id: qtyOf(id) + qty});

  void decrement(String id) {
    final q = qtyOf(id);
    if (q <= 1) {
      remove(id);
    } else {
      _set({...state.items, id: q - 1});
    }
  }

  void remove(String id) => _set({...state.items}..remove(id));

  void clear() {
    state = const CartState();
    _persist();
  }

  /// Returns false when the code is unknown.
  bool applyPromo(String code) {
    if (Promos.find(code) == null) return false;
    state = CartState(items: state.items, promo: code.trim().toUpperCase());
    _persist();
    return true;
  }

  void removePromo() {
    state = CartState(items: state.items);
    _persist();
  }

  void _set(Map<String, int> items) {
    state = CartState(items: items, promo: state.promo);
    _persist();
  }

  void _persist() {
    ref.read(localStoreProvider).writeJson(_key, {'items': state.items, 'promo': state.promo});
  }
}

final cartProvider = NotifierProvider<CartController, CartState>(CartController.new);

/// Quantity of one product in the cart (rebuilds only that product's widgets).
final cartQtyProvider = Provider.family<int, String>(
  (ref, id) => ref.watch(cartProvider.select((s) => s.items[id] ?? 0)),
);

final cartSummaryProvider = Provider<CartSummary>((ref) {
  final cart = ref.watch(cartProvider);
  final catalog = ref.watch(catalogProvider);
  final lines = <CartLine>[];
  for (final entry in cart.items.entries) {
    final product = catalog.product(entry.key);
    if (product != null) lines.add(CartLine(product, entry.value));
  }
  return CartSummary.compute(lines, cart.promo);
});
