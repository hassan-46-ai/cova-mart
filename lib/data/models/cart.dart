import 'dart:math' as math;

import '../../core/config/app_config.dart';
import 'product.dart';

class Promo {
  const Promo({required this.percent, required this.maxOff});

  final int percent;
  final double maxOff;

  double discountFor(double subtotal) => math.min(subtotal * percent / 100, maxOff);
}

/// Demo promo codes. Replace with a server-side check when a backend exists.
abstract final class Promos {
  static const all = <String, Promo>{
    'COVA25': Promo(percent: 25, maxOff: 100),
    'COVA10': Promo(percent: 10, maxOff: 50),
  };

  static Promo? find(String code) => all[code.trim().toUpperCase()];
}

class CartLine {
  const CartLine(this.product, this.qty);

  final Product product;
  final int qty;

  double get total => product.price * qty;
}

/// Priced view of the cart: everything the cart & checkout screens display.
class CartSummary {
  CartSummary._({
    required this.lines,
    required this.promoCode,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
  });

  factory CartSummary.compute(List<CartLine> lines, String? promoCode) {
    final subtotal = lines.fold<double>(0, (s, l) => s + l.total);
    final promo = promoCode == null ? null : Promos.find(promoCode);
    final discount = promo?.discountFor(subtotal) ?? 0;
    final afterDiscount = subtotal - discount;
    final fee = lines.isEmpty || afterDiscount >= AppConfig.freeDeliveryFrom ? 0.0 : AppConfig.deliveryFee;
    return CartSummary._(
      lines: lines,
      promoCode: promo == null ? null : promoCode!.trim().toUpperCase(),
      itemCount: lines.fold<int>(0, (s, l) => s + l.qty),
      subtotal: subtotal,
      discount: discount,
      deliveryFee: fee,
    );
  }

  final List<CartLine> lines;
  final String? promoCode;
  final int itemCount;
  final double subtotal;
  final double discount;
  final double deliveryFee;

  bool get isEmpty => lines.isEmpty;
  double get total => subtotal - discount + deliveryFee;
  bool get meetsMinimum => subtotal >= AppConfig.minOrder;
  double get minimumRemaining => math.max(0, AppConfig.minOrder - subtotal);
  double get freeDeliveryRemaining => math.max(0, AppConfig.freeDeliveryFrom - (subtotal - discount));
  double get freeDeliveryProgress =>
      ((subtotal - discount) / AppConfig.freeDeliveryFrom).clamp(0.0, 1.0).toDouble();
}
