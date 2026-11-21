import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/qty_stepper.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/cart.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promo = TextEditingController();

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  void _apply(String code) {
    final ok = ref.read(cartProvider.notifier).applyPromo(code);
    final l10n = context.l10n;
    showCovaSnack(context, ok ? l10n.promoApplied : l10n.promoInvalid);
    if (ok) {
      _promo.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final summary = ref.watch(cartSummaryProvider);
    final cart = ref.read(cartProvider.notifier);

    return Scaffold(
      bottomNavigationBar: summary.isEmpty ? null : _SummaryBar(summary: summary),
      body: Column(
        children: [
          _CartBanner(count: summary.itemCount, onTapCode: () => _apply('COVA25')),
          Expanded(
            child: summary.isEmpty
                ? EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: l10n.cartEmpty,
                    subtitle: l10n.cartEmptyBody,
                    actionLabel: l10n.startShopping,
                    onAction: () => context.go('/categories'),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      for (var i = 0; i < summary.lines.length; i++)
                        _CartTile(line: summary.lines[i]).entrance(index: i),
                      const SizedBox(height: 18),
                      _FreeDeliveryProgress(summary: summary),
                      const SizedBox(height: 18),
                      if (summary.promoCode != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: c.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cyan, width: 1.4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_offer_rounded, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${summary.promoCode}  ·  ${l10n.promoApplied}',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                              GestureDetector(
                                onTap: cart.removePromo,
                                child: Icon(Icons.close_rounded, color: c.muted),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promo,
                                textCapitalization: TextCapitalization.characters,
                                textInputAction: TextInputAction.done,
                                onSubmitted: _apply,
                                decoration: InputDecoration(
                                  hintText: l10n.promoCode,
                                  prefixIcon: Icon(Icons.local_offer_outlined, color: c.muted),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: AppButton(label: l10n.apply, onPressed: () => _apply(_promo.text)),
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Cyan promo banner (the design's yellow "25% OFF" header).
class _CartBanner extends StatelessWidget {
  const _CartBanner({required this.count, required this.onTapCode});

  final int count;
  final VoidCallback onTapCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 10, 20, 0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cyan, Color(0xFF14CFC7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: 12),
              Text(
                l10n.cartTitle(count),
                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('25%', style: TextStyle(color: AppColors.black, fontSize: 64, height: 1.1, fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l10n.promoOff, style: const TextStyle(color: AppColors.black, fontSize: 22, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          Pressable(
            onTap: onTapCode,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                l10n.useCodeHint,
                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartTile extends ConsumerWidget {
  const _CartTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final lang = context.lang;
    final l10n = context.l10n;
    final cart = ref.read(cartProvider.notifier);
    final p = line.product;

    return Dismissible(
      key: ValueKey('cart-${p.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        final qty = line.qty;
        cart.remove(p.id);
        showCovaSnack(context, l10n.removedFromCart, actionLabel: l10n.undo, onAction: () => cart.add(p.id, qty: qty));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.line),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.push('/product/${p.id}'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(width: 64, height: 64, child: ProductImage(path: p.image, categoryId: p.categoryId, cacheWidth: 200)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name(lang), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(p.unit(lang), style: TextStyle(color: c.muted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(Fmt.money(context, line.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            QtyStepper(
              compact: true,
              qty: line.qty,
              onIncrement: () => cart.add(p.id),
              onDecrement: () => cart.decrement(p.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeDeliveryProgress extends StatelessWidget {
  const _FreeDeliveryProgress({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final free = summary.freeDeliveryRemaining <= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining_rounded, color: free ? AppColors.success : c.text),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  free ? l10n.freeDeliveryUnlocked : l10n.addForFreeDelivery(Fmt.money(context, summary.freeDeliveryRemaining)),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: summary.freeDeliveryProgress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: c.cardAlt,
              color: free ? AppColors.success : AppColors.cyan,
            ),
          ),
        ],
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  const PriceRow({super.key, required this.label, required this.value, this.bold = false, this.valueColor});

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: bold ? c.text : c.muted, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 17 : 14)),
          ),
          Text(value, style: TextStyle(color: valueColor, fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontSize: bold ? 19 : 14)),
        ],
      ),
    );
  }
}

/// Price breakdown. Shared by cart bottom bar and checkout.
class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({super.key, required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        PriceRow(label: l10n.subtotal, value: Fmt.money(context, summary.subtotal)),
        if (summary.discount > 0)
          PriceRow(label: l10n.discount, value: '-${Fmt.money(context, summary.discount)}', valueColor: AppColors.success),
        PriceRow(
          label: l10n.deliveryFee,
          value: summary.deliveryFee == 0 ? l10n.free : Fmt.money(context, summary.deliveryFee),
          valueColor: summary.deliveryFee == 0 ? AppColors.success : null,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider()),
        PriceRow(label: l10n.total, value: Fmt.money(context, summary.total), bold: true),
      ],
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 18, 24, 16 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: c.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PriceBreakdown(summary: summary),
          if (!summary.meetsMinimum)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.minOrderWarning(Fmt.money(context, summary.minimumRemaining)),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          const SizedBox(height: 14),
          AppButton(
            label: l10n.proceedToCheckout,
            icon: Icons.arrow_forward,
            onPressed: summary.meetsMinimum ? () => context.push('/checkout') : null,
          ),
        ],
      ),
    );
  }
}
