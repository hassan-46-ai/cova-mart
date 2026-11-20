import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../data/models/order.dart';
import '../checkout/checkout_screen.dart' show DeliverySlotLabel;
import '../map/osm_tile_layer.dart';
import 'order_status_ui.dart';
import 'orders_controller.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final order = ref.watch(orderByIdProvider(orderId));
    final now = ref.watch(nowProvider).value ?? DateTime.now();

    if (order == null) {
      return Scaffold(
        appBar: AppBar(leading: const Padding(padding: EdgeInsets.all(8), child: AppBackButton())),
        body: EmptyState(icon: Icons.receipt_long_outlined, title: l10n.noOrders, subtitle: ''),
      );
    }

    final status = order.statusAt(now);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.lang;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 280,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: order.address.point,
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    const OsmTileLayer(),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: order.address.point,
                          width: 56,
                          height: 56,
                          alignment: Alignment.topCenter,
                          child: Icon(Icons.location_on_rounded, size: 52, color: dark ? AppColors.cyan : AppColors.black),
                        ),
                      ],
                    ),
                    const OsmAttribution(),
                  ],
                ),
                const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: AppBackButton(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: BoxDecoration(color: c.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('#${order.id}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                      Text(Fmt.money(context, order.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${l10n.deliveryTime}: ${order.slot.label(l10n)}', style: TextStyle(color: c.muted)),
                  const SizedBox(height: 22),
                  _Timeline(current: status),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: c.line)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(order.address.details, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4))),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                        for (final line in order.lines)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(width: 40, height: 40, child: ProductImage(path: line.image, categoryId: '', cacheWidth: 140)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text('${line.qty} × ${line.name(lang)}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                Text(Fmt.money(context, line.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.current});

  final OrderStatus current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    const steps = OrderStatus.values;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: c.line)),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            _Step(
              status: steps[i],
              label: steps[i].label(l10n),
              done: steps[i].index < current.index || current == OrderStatus.delivered,
              active: steps[i] == current && current != OrderStatus.delivered,
              last: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.status, required this.label, required this.done, required this.active, required this.last});

  final OrderStatus status;
  final String label;
  final bool done;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reached = done || active;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached ? c.fab : c.cardAlt,
                  border: active ? Border.all(color: AppColors.cyan, width: 3) : null,
                ),
                child: Icon(done ? Icons.check_rounded : status.icon, size: 20, color: reached ? c.onFab : c.muted),
              ),
              if (!last)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: done ? AppColors.cyan : c.line),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 9, bottom: last ? 0 : 22),
              child: Text(
                label,
                style: TextStyle(fontWeight: reached ? FontWeight.w800 : FontWeight.w500, color: reached ? c.text : c.muted, fontSize: 15.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
