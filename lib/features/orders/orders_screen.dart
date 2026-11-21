import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cova_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/order.dart';
import 'order_status_ui.dart';
import 'orders_controller.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  bool _showActive = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = ref.watch(ordersProvider);
    final fresh = orders.any((o) => DateTime.now().difference(o.createdAt) < const Duration(minutes: 6));
    final now = fresh ? (ref.watch(nowProvider).value ?? DateTime.now()) : DateTime.now();
    final shown = orders.where((o) => o.statusAt(now).isActive == _showActive).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  Text(l10n.myOrders, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  CovaChip(label: l10n.active, selected: _showActive, onTap: () => setState(() => _showActive = true)),
                  const SizedBox(width: 8),
                  CovaChip(label: l10n.past, selected: !_showActive, onTap: () => setState(() => _showActive = false)),
                ],
              ),
            ),
            Expanded(
              child: shown.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.noOrders,
                      subtitle: l10n.noOrdersBody,
                      actionLabel: l10n.startShopping,
                      onAction: () => context.go('/categories'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: shown.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _OrderCard(order: shown[i], now: now).entrance(index: i),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final status = order.statusAt(now);
    final extra = order.lines.length - 4;

    return Pressable(
      onTap: () => context.push('/order/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: c.line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.isActive ? AppColors.cyan : c.cardAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.label(l10n),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: status.isActive ? AppColors.black : c.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(Fmt.dateTime(context, order.createdAt), style: TextStyle(color: c.muted, fontSize: 12.5)),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final line in order.lines.take(4))
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    width: 48,
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: c.cardAlt),
                    child: ProductImage(path: line.image, categoryId: '', cacheWidth: 140),
                  ),
                if (extra > 0) Text('+$extra', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.itemsCount(order.itemCount)}  ·  ${Fmt.money(context, order.total)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(ordersProvider.notifier).reorder(order);
                    showCovaSnack(context, l10n.itemsAddedToCart, actionLabel: l10n.viewCart, onAction: () => context.push('/cart'));
                  },
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: Text(l10n.reorder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
