import 'address.dart';
import 'cart.dart';

enum PaymentMethod { cash, card }

enum DeliverySlot { asap, withinHour, evening, tomorrow }

enum OrderStatus { placed, preparing, onTheWay, delivered }

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.unitEn,
    required this.unitAr,
    required this.image,
    required this.unitPrice,
    required this.qty,
  });

  factory OrderLine.fromCartLine(CartLine l) => OrderLine(
        productId: l.product.id,
        nameEn: l.product.nameEn,
        nameAr: l.product.nameAr,
        unitEn: l.product.unitEn,
        unitAr: l.product.unitAr,
        image: l.product.image,
        unitPrice: l.product.price,
        qty: l.qty,
      );

  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
        productId: j['productId'] as String,
        nameEn: j['nameEn'] as String,
        nameAr: j['nameAr'] as String,
        unitEn: j['unitEn'] as String,
        unitAr: j['unitAr'] as String,
        image: j['image'] as String,
        unitPrice: (j['unitPrice'] as num).toDouble(),
        qty: (j['qty'] as num).toInt(),
      );

  final String productId;
  final String nameEn;
  final String nameAr;
  final String unitEn;
  final String unitAr;
  final String image;
  final double unitPrice;
  final int qty;

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String unit(String lang) => lang == 'ar' ? unitAr : unitEn;
  double get total => unitPrice * qty;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'unitEn': unitEn,
        'unitAr': unitAr,
        'image': image,
        'unitPrice': unitPrice,
        'qty': qty,
      };
}

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.address,
    required this.payment,
    required this.slot,
    this.cardLast4,
    this.note,
    this.promoCode,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        lines: [for (final l in j['lines'] as List) OrderLine.fromJson(l as Map<String, dynamic>)],
        subtotal: (j['subtotal'] as num).toDouble(),
        discount: (j['discount'] as num).toDouble(),
        deliveryFee: (j['deliveryFee'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
        address: Address.fromJson(j['address'] as Map<String, dynamic>),
        payment: PaymentMethod.values.byName(j['payment'] as String),
        slot: DeliverySlot.values.byName(j['slot'] as String),
        cardLast4: j['cardLast4'] as String?,
        note: j['note'] as String?,
        promoCode: j['promoCode'] as String?,
      );

  final String id;
  final DateTime createdAt;
  final List<OrderLine> lines;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final Address address;
  final PaymentMethod payment;
  final DeliverySlot slot;
  final String? cardLast4;
  final String? note;
  final String? promoCode;

  int get itemCount => lines.fold(0, (s, l) => s + l.qty);

  /// DEMO TIMELINE: seconds after placing when each status begins.
  /// Used by both the tracking screen and the scheduled notifications.
  /// Replace with real status events from your backend.
  static const stageSeconds = <OrderStatus, int>{
    OrderStatus.preparing: 40,
    OrderStatus.onTheWay: 120,
    OrderStatus.delivered: 300,
  };

  OrderStatus statusAt(DateTime now) {
    final s = now.difference(createdAt).inSeconds;
    if (s >= stageSeconds[OrderStatus.delivered]!) return OrderStatus.delivered;
    if (s >= stageSeconds[OrderStatus.onTheWay]!) return OrderStatus.onTheWay;
    if (s >= stageSeconds[OrderStatus.preparing]!) return OrderStatus.preparing;
    return OrderStatus.placed;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'lines': [for (final l in lines) l.toJson()],
        'subtotal': subtotal,
        'discount': discount,
        'deliveryFee': deliveryFee,
        'total': total,
        'address': address.toJson(),
        'payment': payment.name,
        'slot': slot.name,
        'cardLast4': cardLast4,
        'note': note,
        'promoCode': promoCode,
      };
}
