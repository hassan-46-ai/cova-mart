import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_controller.dart';
import '../../data/models/address.dart';
import '../../data/models/cart.dart';
import '../../data/models/order.dart';
import '../../data/services/local_store.dart';
import '../auth/auth_controller.dart';
import '../cart/cart_controller.dart';

class OrdersController extends Notifier<List<Order>> {
  late String _key;

  @override
  List<Order> build() {
    _key = StoreKeys.orders(ref.watch(userIdProvider));
    final raw = ref.read(localStoreProvider).readJson(_key);
    if (raw is! List) return const [];
    return [for (final o in raw) Order.fromJson(Map<String, dynamic>.from(o as Map))];
  }

  /// Creates the order from the current cart, then empties the cart.
  Order place({
    required CartSummary summary,
    required Address address,
    required PaymentMethod payment,
    required DeliverySlot slot,
    String? cardLast4,
    String? note,
  }) {
    final order = Order(
      id: 'CV${100000 + Random().nextInt(900000)}',
      createdAt: DateTime.now(),
      lines: [for (final l in summary.lines) OrderLine.fromCartLine(l)],
      subtotal: summary.subtotal,
      discount: summary.discount,
      deliveryFee: summary.deliveryFee,
      total: summary.total,
      address: address,
      payment: payment,
      slot: slot,
      cardLast4: cardLast4,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      promoCode: summary.promoCode,
    );
    state = [order, ...state];
    ref.read(localStoreProvider).writeJson(_key, [for (final o in state) o.toJson()]);
    ref.read(cartProvider.notifier).clear();

    final settings = ref.read(settingsProvider);
    if (settings.notificationsEnabled) {
      unawaited(ref.read(notificationServiceProvider).scheduleOrderUpdates(order, settings.locale));
    }
    return order;
  }

  /// Adds every still-available item of a past order back into the cart.
  void reorder(Order order) {
    final catalog = ref.read(catalogProvider);
    final cart = ref.read(cartProvider.notifier);
    for (final line in order.lines) {
      final product = catalog.product(line.productId);
      if (product != null && product.inStock) cart.add(product.id, qty: line.qty);
    }
  }
}

final ordersProvider = NotifierProvider<OrdersController, List<Order>>(OrdersController.new);

final orderByIdProvider = Provider.family<Order?, String>((ref, id) {
  for (final o in ref.watch(ordersProvider)) {
    if (o.id == id) return o;
  }
  return null;
});

/// Ticks every 2 seconds so order-status widgets refresh themselves.
final nowProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 2), (_) => DateTime.now());
});
