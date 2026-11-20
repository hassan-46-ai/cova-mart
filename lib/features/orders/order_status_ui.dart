import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../data/models/order.dart';

extension OrderStatusUi on OrderStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case OrderStatus.placed:
        return l10n.statusPlaced;
      case OrderStatus.preparing:
        return l10n.statusPreparing;
      case OrderStatus.onTheWay:
        return l10n.statusOnTheWay;
      case OrderStatus.delivered:
        return l10n.statusDelivered;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.placed:
        return Icons.receipt_long_rounded;
      case OrderStatus.preparing:
        return Icons.shopping_basket_rounded;
      case OrderStatus.onTheWay:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
    }
  }

  bool get isActive => this != OrderStatus.delivered;
}
